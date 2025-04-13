require 'kmeans-clusterer'
require 'faraday'
require 'shellwords'
require 'openai'
class ContactsController < ApplicationController
  before_action :authenticate_user!

  def index
    @list_of_contacts = Contact.where(user_id: current_user.id).order(created_at: :desc)
    render({ template: "contacts/index" })
  end

  def show
    if current_user
      the_id = params.fetch("path_id", nil)
      if the_id
        @the_contact = Contact.find_by(id: the_id, user_id: current_user.id)
        @chart_data = []
        #last_event_date = nil
        relationship_strength = 50
        start_date = @the_contact.date_first_met || Event.all.order(:event_date).first.event_date
        @chart_data << { date: start_date.strftime("%Y-%m-%d"), value: relationship_strength, id: nil }
      last_event_date = start_date
      @the_contact.events.order(:event_date).each do |event|
        if last_event_date
          month_gap = ((event.event_date.year - last_event_date.year) * 12 + event.event_date.month - last_event_date.month)
          if month_gap > 12 
            depreciation = 5 * (month_gap / 6)
            relationship_strength -= depreciation
            relationship_strength = [relationship_strength, 20].max
          end
        end

          @chart_data << {
          date: event.event_date.strftime("%Y-%m-%d"),
          value: relationship_strength, 
          id: nil
        }
          case event.intention
          when "Request"
            relationship_strength += 2
          when "Keeping in touch"
            relationship_strength += 20
          else
            relationship_strength += 15
          end
          relationship_strength = [[relationship_strength, 0].max, 100].min
          @chart_data << {
            date: event.event_date.strftime("%Y-%m-%d"),
            value: relationship_strength, 
            id: event.id
          }
          
          last_event_date = event.event_date
          #@chart_data << { date: event.event_date, value: relationship_strength, id: event.id }
        end

        if Date.today > last_event_date
          @chart_data << { date: Date.today.strftime("%Y-%m-%d"), value: relationship_strength, id: nil }
        end
      else
        redirect_to("/contacts", alert: "Contact not found or you don't have permission to view this contact.")
      end
    else
      redirect_to new_user_session_path
    end
  end
  

  def create
    the_contact = Contact.new(
      first_name: params.fetch("query_first_name"),
      last_name: params.fetch("query_last_name"),
      email: params.fetch("query_email"),
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
      first_name: params.fetch("query_first_name"),
      last_name: params.fetch("query_last_name"),
      email: params.fetch("query_email"),
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

  def send_email
    @the_contact = Contact.find(params[:id])
    recipient_email = params[:recipient_email].presence || "default@example.com"
    subject = params[:subject].presence || "No Subject"
    body = params[:body].presence || "No Body"
  
    # Escape parameters
    command = "node nodemailer_service/mailer.js #{Shellwords.escape(recipient_email)} #{Shellwords.escape(subject)} #{Shellwords.escape(body)}"
    Rails.logger.info("Command to execute: #{command}")
  
    stdout, stderr, status = Open3.capture3(command)
  
    if status.success?
      flash[:notice] = "Email sent successfully!"
    else
      Rails.logger.error("Error sending email: #{stderr}")
      flash[:alert] = "Error sending email: #{stderr}"
    end
  
    redirect_to contact_path(@the_contact)
  end

  def starting_relationship_strength(contact)
    # Return the default value if there's no how_met note
    return 50 unless contact.how_met.present?
    
    # Get the embedding for the how_met note using your get_embeddings_for_text method
    embedding = get_embeddings_for_text(contact.how_met)

    clusters = [
      { center: [0.1, 0.2, 0.3, 0.4], strength: 40 },
      { center: [0.5, 0.6, 0.7, 0.8], strength: 60 },
      { center: [0.9, 1.0, 1.1, 1.2], strength: 70 }
    ]
    
    # Use the kmeans-clusterer (or a simple distance calculation) to assign the new embedding
    best_cluster = clusters.min_by do |cluster|
      euclidean_distance(embedding, cluster[:center])
    end
    
    # Use the cluster's associated strength as the starting value
    best_cluster ? best_cluster[:strength] : 50
  end
  
  # A helper method for Euclidean distance (assuming both arrays are the same length)
  def euclidean_distance(vec1, vec2)
    Math.sqrt(vec1.zip(vec2).map { |a, b| (a - b)**2 }.sum)
  end
end  
