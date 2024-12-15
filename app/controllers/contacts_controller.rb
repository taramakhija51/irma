class ContactsController < ApplicationController
  # List all contacts for the current user
  def index
    @list_of_contacts = Contact.where(user_id: current_user.id).order(created_at: :desc)
    render({ template: "contacts/index" })
  end

  # Show details of a specific contact
  def show
    the_id = params.fetch("path_id")
    @the_contact = Contact.find_by(id: the_id, user_id: current_user.id)

    if @the_contact.nil?
      redirect_to("/contacts", alert: "Contact not found or you don't have permission to view this contact.")
      return
    end
  
    # In your controller:
    @chart_data = []
    last_event_date = nil
    relationship_strength = 0

    Event.all.order(:event_date).each do |event|
      # Calculate depreciation over time
      if last_event_date
        month_gap = ((event.event_date.year - last_event_date.year) * 12 + event.event_date.month - last_event_date.month)
        if month_gap > 6
          relationship_strength -= (month_gap / 6)
        end
      end

      # Adjust relationship_strength based on event intention
      case event.intention
      when "Request"
        relationship_strength -= 1
      when "Keeping in touch"
        relationship_strength += 5
      else
        relationship_strength += 3
      end

      # Store the event data for the chart, including the relationship_strength
      @chart_data << {
        date: event.event_date.strftime("%Y-%m-%d"),
        value: relationship_strength,  # Use relationship_strength as the value
        id: event.id
      }

      last_event_date = event.event_date  # Update the last_event_date for next iteration
    end
  end
  # Create a new contact
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

  # Update an existing contact
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

  # Delete a contact
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
