class ContactsController < ApplicationController
  def index
    matching_contacts = Contact.all

    @list_of_contacts = matching_contacts.order({ :created_at => :desc })

    render({ :template => "contacts/index" })
  end

  def show
    the_id = params.fetch("path_id")

    matching_contacts = Contact.where({ :id => the_id })

    @the_contact = matching_contacts.at(0)

    render({ :template => "contacts/show" })
  end

  def create
    the_contact = Contact.new
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
      redirect_to("/contacts", { :notice => "Contact created successfully." })
    else
      redirect_to("/contacts", { :alert => the_contact.errors.full_messages.to_sentence })
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

  has_many(:interactions,
  class_name: "Interaction",
  foreign_key: "contact_id"
)

belongs_to(:user,
class_name: "User",
foreign_key: "user_id"
)
end
