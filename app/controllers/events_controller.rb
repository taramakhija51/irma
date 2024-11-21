class EventsController < ApplicationController
  def index
    matching_events = Event.all

    @list_of_events = matching_events.order({ :created_at => :desc })

    render({ :template => "events/index" })
  end

  def show
    the_id = params.fetch("path_id")

    matching_events = Event.where({ :id => the_id })

    @the_event = matching_events.at(0)

    render({ :template => "events/show" })
  end

  def create
    the_event = Event.new
    the_event.event_type = params.fetch("query_event_type")
    the_event.event_date = params.fetch("query_event_date")
    the_event.event_location = params.fetch("query_event_location")
    the_event.contact_id = params.fetch("query_contact_id")
    the_event.user_id = params.fetch("query_user_id")
    the_event.intention = params.fetch("query_intention")

    if the_event.valid?
      the_event.save
      redirect_to("/events", { :notice => "Event created successfully." })
    else
      redirect_to("/events", { :alert => the_event.errors.full_messages.to_sentence })
    end
  end

  def update
    the_id = params.fetch("path_id")
    the_event = Event.where({ :id => the_id }).at(0)

    the_event.event_type = params.fetch("query_event_type")
    the_event.event_date = params.fetch("query_event_date")
    the_event.event_location = params.fetch("query_event_location")
    the_event.contact_id = params.fetch("query_contact_id")
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

  has_many(:contacts,
  through: :interactions,
  source: :contact
)

has_many(:interactions,
    class_name: "Interaction",
    foreign_key: "event_id"
  )
end
