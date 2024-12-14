class ContactsController < ApplicationController
  # List all contacts for the current user
  def index
    @list_of_contacts = Contact.where(user_id: current_user.id).order(created_at: :desc)
    render({ :template => "contacts/index" })
  end

  # Show details of a specific contact
  def show
    the_id = params.fetch("path_id")
    @the_contact = Contact.find_by(id: the_id, user_id: current_user.id)
  
    if @the_contact.nil?
      redirect_to("/contacts", alert: "Contact not found or you don't have permission to view this contact.")
      return # Ensure no further code is executed if the contact is not found
    end
  
    events = @the_contact.events.order(:event_date)
    relationship_strength = 0
    data_points = []
    last_event_date = nil
  
    events.each do |event|
      # Calculate the year gap between the current and last event
      year_gap = last_event_date ? event.event_date.year - last_event_date.year : 0
      relationship_strength -= year_gap if year_gap > 0
  
      # Adjust relationship strength based on event intention
      case event.intention
      when "request"
        relationship_strength -= 1
      when "keeping in touch"
        relationship_strength += 2
      else
        relationship_strength += 1
      end
  
      # Collect data points for the chart
      data_points << { date: event.event_date.strftime("%Y-%m-%d"), value: relationship_strength }
  
      # Update last event date for the next iteration
      last_event_date = event.event_date
    end
  
    # Pass the chart data to the view
    @chart_data = data_points
  end

  # Create a new contact
  def create
    Rails.logger.debug(params.inspect) # Debugging
    Rails.logger.debug "Current User: #{current_user.inspect}"
    the_user = User.where(id: current_user.id).first
    Rails.logger.debug "Fetched User: #{the_user.inspect}"
    if the_user.nil?
      Rails.logger.debug "No user found with ID #{current_user.id}. User is likely not logged in."
      redirect_to("/login", alert: "You must be logged in to create a contact.")
      return
    end

    the_contact = Contact.new(contact_params)

    if the_contact.save
      redirect_to("/contacts", { notice: "Contact created successfully." })
    else
      Rails.logger.debug(the_contact.errors.full_messages)  # Check the error messages for details
      redirect_to("/contacts", { alert: the_contact.errors.full_messages.to_sentence })
    end
  end

  # Update an existing contact
  def update
    the_id = params.fetch("path_id")
    the_contact = Contact.where({ :id => the_id, user_id: current_user.id }).first

    if the_contact.nil?
      redirect_to("/contacts", alert: "Contact not found or you don't have permission to edit this contact.")
      return
    end

    the_contact.update(contact_params)

    if the_contact.valid?
      redirect_to("/contacts/#{the_contact.id}", { notice: "Contact updated successfully." })
    else
      redirect_to("/contacts/#{the_contact.id}", { alert: the_contact.errors.full_messages.to_sentence })
    end
  end

  # Delete a contact
  def destroy
    the_id = params.fetch("path_id")
    the_contact = Contact.where({ :id => the_id, user_id: current_user.id }).first

    if the_contact.nil?
      redirect_to("/contacts", alert: "Contact not found or you don't have permission to delete this contact.")
      return
    end

    the_contact.destroy
    redirect_to("/contacts", { notice: "Contact deleted successfully." })
  end

  private

  # Strong parameters for creating and updating contacts
  def contact_params
    params.require(:contact).permit(
      :first_name, :last_name, :date_first_met, :current_employer, :partner,
      :most_recent_contact_date, :communication_frequency, :industry, :role,
      :user_id, :introduced_by_id, :how_met, :notes
    )
  end
end
