class ContactsController < ApplicationController
  def index
    @list_of_contacts = Contact.where(user_id: current_user.id).order(created_at: :desc)
    render({ :template => "contacts/index" })

  end

  def show
    the_id = params.fetch("path_id")
    @the_contact = Contact.find_by(id: the_id, user_id: current_user.id)
    events = @the_contact.events.order(:event_date)
    relationship_strength = 0
    data_points = []
    last_event_date = nil
    events.each do |event|
      year_gap = last_event_date ? event.event_date.year - last_event_date.year : 0
      relationship_strength -= year_gap if year_gap > 0
      case event.intention
      when "request"
        relationship_strength -= 1
      when "keeping in touch"
        relationship_strength += 2
      else
        relationship_strength += 1
      end
      data_points << { date: event.event_date.strftime("%Y-%m-%d"), value: relationship_strength }

      last_event_date = event.event_date
    end

    @chart_data = data_points
  end
end
    if @the_contact.nil?
      redirect_to("/contacts", alert: "Contact not found or you don't have permission to view this contact.")
    else
      render({ :template => "contacts/show" })
    end



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
    the_contact = Contact.new(
      first_name: params["query_first_name"],
      last_name: params["query_last_name"],
      date_first_met: params["query_date_first_met"],
      current_employer: params["query_current_employer"],
      partner: params["query_partner"],
      most_recent_contact_date: params["query_most_recent_contact_date"],
      communication_frequency: params["query_communication_frequency"],
      industry: params["query_industry"],
      role: params["query_role"],
      user_id: current_user.id,
      introduced_by_id: params["query_introduced_by_id"],
      how_met: params["query_how_met"],
      notes: params["query_notes"]
    )
  
    if the_contact.save
      redirect_to("/contacts", { notice: "Contact created successfully." })
    else
      Rails.logger.debug(the_contact.errors.full_messages)  # Check the error messages for details
      redirect_to("/contacts", { alert: the_contact.errors.full_messages.to_sentence })
    end
  end
  
  

  def update
    the_id = params.fetch("path_id")
    the_contact = Contact.where({ :id => the_id }).at(0)

    the_contact.date_first_met = params.fetch("query_date_first_met")
    the_contact.current_employer = params.fetch("query_current_employer")
    the_contact.partner = params.fetch("query_partner")
    the_contact.most_recent_contact_date = params.fetch("query_most_recent_contact_date")
    the_contact.communication_frequency = params.fetch("query_communication_frequency")
    the_contact.industry = params.fetch("query_industry")
    the_contact.role = params.fetch("query_role")
    the_contact.user_id = params.fetch("query_user_id")
    the_contact.integer = params.fetch("query_integer")
    the_contact.introduced_by_id = params.fetch("query_introduced_by_id")
    the_contact.how_met = params.fetch("query_how_met")
    the_contact.notes = params.fetch("query_notes")

    if the_contact.valid?
      the_contact.save
      redirect_to("/contacts/#{the_contact.id}", { :notice => "Contact updated successfully."} )
    else
      redirect_to("/contacts/#{the_contact.id}", { :alert => the_contact.errors.full_messages.to_sentence })
    end
  end

  def destroy
    the_id = params.fetch("path_id")
    the_contact = Contact.where({ :id => the_id }).at(0)

    the_contact.destroy

    redirect_to("/contacts", { :notice => "Contact deleted successfully."} )
  end



