require 'kmeans-clusterer'
require 'faraday'
class ContactsController < ApplicationController
  def index
    @list_of_contacts = Contact.where(user_id: current_user.id).order(created_at: :desc)
    render({ template: "contacts/index" })
  end

  def show
    the_id = params.fetch("path_id")
    @the_contact = Contact.find_by(id: the_id, user_id: current_user.id)
  
    if @the_contact.nil?
      redirect_to("/contacts", alert: "Contact not found or you don't have permission to view this contact.")
      return
    end
  
    # Step 1: Pluck and filter the "How Met" column
    contacts = Contact.where(user_id: current_user.id).pluck(:how_met).map(&:strip).reject(&:blank?)
  
    if contacts.empty?
      raise "No valid text data in 'How Met' column for embeddings."
    end
  
    # Log the raw data for debugging
    Rails.logger.debug("Contacts 'How Met' data: #{contacts.inspect}")
  

    # Step 2: Generate embeddings
    all_embeddings = contacts.map do |text|
      begin
        embedding = get_embeddings_for_text(text)
        Rails.logger.debug("Text: #{text}, Embedding: #{embedding.inspect}")
        embedding
      rescue => e
        Rails.logger.error("Failed to generate embedding for text '#{text}': #{e.message}")
        nil
      end
    end.compact

    if all_embeddings.empty?
      raise "No valid embeddings generated from 'How Met' data."
    end

    # Log embeddings for inspection
    Rails.logger.debug("Generated embeddings: #{all_embeddings.inspect}")

    # Perform K-Means clustering
    # Step 4: Perform clustering
    kmeans = KMeansClusterer.run(3, all_embeddings, runs: 100, random_seed: 42)

    # Log cluster centroids for debugging
    Rails.logger.debug("Cluster centroids: #{kmeans.centroids.inspect}")

    # Find the embedding for the current contact
    contact_embedding = get_embeddings_for_text(@the_contact.how_met)

    # Assign the current contact to a cluster
    contact_cluster = kmeans.closest_centroid(contact_embedding)

    # Step 5: Calculate starting relationship strength based on the cluster
    @starting_relationship_strength = calculate_relationship_strength(contact_cluster)


    # Generate the chart data (using the calculated relationship strength)
    relationship_strength = 0
    @chart_data = generate_chart_data(@the_contact, relationship_strength)

    # Prepare relationship strength over events (you had this part after the `end` keyword inappropriately)
    @chart_data_event = []
    last_event_date = nil
  

    Event.all.order(:event_date).each do |event|
      if last_event_date
        month_gap = ((event.event_date.year - last_event_date.year) * 12 + event.event_date.month - last_event_date.month)
        if month_gap > 6
          relationship_strength -= (month_gap / 6)
        end
      end

      case event.intention
      when "Request"
        relationship_strength -= 1
      when "Keeping in touch"
        relationship_strength += 5
      else
        relationship_strength += 3
      end

      @chart_data_event << {
        date: event.event_date.strftime("%Y-%m-%d"),
        value: relationship_strength,  
        id: event.id
      }

      last_event_date = event.event_date 
    end
  end

  def calculate_relationship_strength(cluster)
    case cluster
    when 0
      2  # Example value for cluster 0
    when 1
      4  # Example value for cluster 1
    when 2
      6  # Example value for cluster 2
    else
      0  # Default fallback
    end
  end

  # Helper method to generate the embedding for any text
  def get_embeddings_for_text(text)
    return [] if text.blank? || text.size > 100000
    client = OpenAI::Client.new(api_key: ENV['OPENAI_API_KEY'])
    
    Rails.logger.debug("Fetching embedding for text: #{text}")
    
    response = client.embeddings(
      parameters: {
        model: 'text-embedding-ada-002', # or 'text-embedding-3-large'
        input: text
      }
    )
    
    # Log the response for debugging
    Rails.logger.debug("API Response: #{response.inspect}")
    
    embedding = response['data'].first['embedding']
    raise "Empty embedding" if embedding.nil? || embedding.empty?
  
    embedding
  rescue OpenAI::ClientError => e
    Rails.logger.error("Error fetching embedding for text '#{text}': #{e.message}")
    # You can return an empty array or a default value here
    []
  rescue => e
    Rails.logger.error("Unexpected error fetching embedding for text '#{text}': #{e.message}")
    []
  end

  def generate_chart_data(contact, relationship_strength)
    data_points = []
    last_event_date = nil
    relationship_strength = 0

    contact.events.order(:event_date).each do |event|
      case event.intention
      when "request"
        relationship_strength -= 1
      when "keeping in touch"
        relationship_strength += 5
      else
        relationship_strength += 3
      end

      data_points << {
        date: event.event_date.strftime("%Y-%m-%d"),
        value: relationship_strength, 
        id: event.id
      }

      last_event_date = event.event_date 
    end

    data_points
  end

  def create
    the_contact = Contact.new(
      first_name: params.fetch("query_first_name"),
      last_name: params.fetch("query_last_name"),
      date_first_met: params.fetch("query_date_first_met"),
      current_employer: params.fetch("query_current_employer"),
      partner: params.fetch("query_partner"),
      most_recent_contact_date: params.fetch("query_most_recent_contact_date"),
      communication_frequency: params.fetch("query_communication_frequency"),
      industry: params.fetch("query_industry"),
      role: params.fetch("query_role"),
      user_id: current_user.id, 
      introduced_by_id: params.fetch("query_introduced_by_id"),
      how_met: params.fetch("query_how_met"),
      notes: params.fetch("query_notes")
    )

    if the_contact.save
      redirect_to("/contacts", notice: "Contact created successfully.")
    else
      redirect_to("/contacts", alert: the_contact.errors.full_messages.to_sentence)
    end
  end

  def update
    the_id = params.fetch("path_id")
    the_contact = Contact.where(id: the_id, user_id: current_user.id).first

    if the_contact.nil?
      redirect_to("/contacts", alert: "Contact not found or you don't have permission to edit this contact.")
      return
    end

    if the_contact.update(
      first_name: params[:first_name],
      last_name: params[:last_name],
      date_first_met: params[:date_first_met],
      current_employer: params[:current_employer],
      partner: params[:partner],
      most_recent_contact_date: params[:most_recent_contact_date],
      communication_frequency: params[:communication_frequency],
      industry: params[:industry],
      role: params[:role],
      user_id: current_user.id,
      introduced_by_id: params[:introduced_by_id],
      how_met: params[:how_met],
      notes: params[:notes]
    )
      redirect_to("/contacts/#{the_contact.id}", notice: "Contact updated successfully.")
    else
      redirect_to("/contacts/#{the_contact.id}", alert: the_contact.errors.full_messages.to_sentence)
    end
  end


  def destroy
    the_id = params.fetch("path_id")
    the_contact = Contact.where(id: the_id, user_id: current_user.id).first

    if the_contact.nil?
      redirect_to("/contacts", alert: "Contact not found or you don't have permission to delete this contact.")
      return
    end

    the_contact.destroy
    redirect_to("/contacts", notice: "Contact deleted successfully.")
  end
end
