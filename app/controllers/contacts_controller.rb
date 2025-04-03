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
      the_id = params.fetch("path_id", nil) # Fetch the path_id, handle missing param gracefully
      if the_id
        @the_contact = Contact.find_by(id: the_id, user_id: current_user.id)
  
        if @the_contact
          Rails.logger.info "Contact found: #{@the_contact.inspect}"
        else
          redirect_to("/contacts", alert: "Contact not found or you don't have permission to view this contact.")
        end
      else
        redirect_to("/contacts", alert: "Invalid contact ID.")
      end
    else
      Rails.logger.info "User not logged in"
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
      first_name: params[:first_name],
      last_name: params[:last_name],
      email: params[:email],
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

  def calculate_relationship_strength(cluster)
    case cluster
    when 0
      2
    when 1
      4
    when 2
      6
    else
      0
    end
  end

  def get_embeddings_for_text(text)
    return [] if text.blank? || text.size > 100000

    client = OpenAI::Client.new(access_token: ENV['OPENAI_API_KEY'])
    response = client.embeddings(parameters: { model: "text-embedding-3-small", input: [text] })
    embedding = response['data'].first['embedding']
    raise "Empty embedding" if embedding.nil? || embedding.empty?
    embedding
  rescue OpenAI::ClientError => e
    Rails.logger.error("Error fetching embedding: #{e.message}")
    []
  end
end
