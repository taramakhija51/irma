class EventsController < ApplicationController
  def index
    matching_events = Event.all

    @list_of_events = matching_events.order({ :created_at => :desc })

    render({ :template => "events/index" })
  end

  def show
    client = OpenAI::Client.new(access_token: ENV['OPENAI_KEY'])
    the_id = params.fetch("path_id")
    user_content = params.fetch("user_content", "")
    matching_events = Event.where({ :id => the_id })

    @the_event = matching_events.at(0)
    @all_contacts = Contact.all
    render({ :template => "events/show" })
  end

  def create
    @event = Event.new(event_params) # Strong parameters
  
    if @event.save
      contact_ids = params[:query_contact_id] || [] # Default to an empty array if no contacts are selected
  
      contact_ids.each do |contact_id|
        Interaction.create(contact_id: contact_id, event_id: @event.id)
      end
  
      redirect_to("/events", notice: "Event and interactions created successfully.")
    else
      render :new, alert: "Event creation failed."
    end
  end
  

  def update
    the_id = params.fetch("path_id")
    the_event = Event.where({ :id => the_id }).at(0)
    @all_contacts = Contact.all
    the_event.event_type = params.fetch("query_event_type")
    the_event.event_date = params.fetch("query_event_date")
    the_event.event_location = params.fetch("query_event_location")
    #the_event.contact_id = params.fetch("query_contact_id")
    contact_ids = params[:query_contact_ids] || []
    the_event.contacts = Contact.where(id: contact_ids) # Assuming a `has_many :contacts` association
    

    the_event.user_id = params.fetch("query_user_id")
    the_event.intention = params.fetch("query_intention")

    if the_event.valid?
      the_event.save
      redirect_to("/events/#{the_event.id}", { :notice => "Event updated successfully."} )
    else
      redirect_to("/events/#{the_event.id}", { :alert => the_event.errors.full_messages.to_sentence })
    end
  end

  
  def destroy
    the_id = params.fetch("path_id")
    the_event = Event.where({ :id => the_id }).at(0)

    the_event.destroy

    redirect_to("/events", { :notice => "Event deleted successfully."} )
  end

 
end
