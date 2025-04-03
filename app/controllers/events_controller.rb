require 'openai'
class EventsController < ApplicationController
  def index
    matching_events = Event.all
    @all_contacts = Contact.all
    @list_of_events = matching_events.order({ :created_at => :desc })
    contact_ids = params[:query_contact_ids] || []
    if contact_ids.any?
      @list_of_events = @list_of_events.joins(:contacts).where(contacts: { id: contact_ids }).distinct
    end
    render({ :template => "events/index" })
  end
  def show
    the_id = params.fetch("path_id")
    @the_event = Event.find_by(id: the_id)
    
    if params[:user_content].present?
      @email = generate_email(@the_event, params[:user_content])
      session[:generated_email] = @email
      redirect_to(event_path(@the_event, email_generated: true)) and return
    end
    @email = session[:generated_email] if params[:email_generated]

    if @the_event
      @all_contacts = Contact.all
    else
      redirect_to(events_path, alert: "Event not found.")
    end
    render({ template: "events/show" })
  end

def generate_email(event, user_content)

  return nil if user_content.blank?
  client = OpenAI::Client.new(api_key: ENV.fetch("OPENAI_API_KEY"))
  message_list = [
    {
      "role" => "system",
          "content" => "Draft a thank you email after networking with someone. You met with them on #{event.event_date} via a format of #{event.event_type}, their name is  #{event.contacts.map { |contact| "#{contact.first_name} #{contact.last_name}" }.join(", ")}.The user will input some takeaways from the meeting. You want the tone to be friendly, but professional, acknowledging the user is likely not very close with the person. Emphasize WARMTH coming across. Keep it under one paragraph. Do NOT give them any fill in the blanks in the email. Try to write something generic about having learned a lot or gained a new perspective if they don't include notes. But DO NOT make it too obvious that it's generic, try to sound as thoughtful and personal as possible. Do not try to kiss up to them, and limit any words that are three syllables or longer. Avoid corporate speak -- do NOT say phrases such as 'valuable insights', 'crossing paths', etc but don't make it too informal. For an example on the level of formality -- phrases like 'I wanted to express my gratitude' are too formal and should NOT be used, opt for phrases like 'I am grateful for' instead. Meanwhile phrases like 'Looking forward to staying in touch' should NOT be used, replaced by the more formal -- 'I look forward to staying in touch' or 'I hope to stay in touch'. Try to find a happy medium between both examples in the general messaging. It should be 4-7 sentences long. Reference the date of the interaction (as inputted by the user). Don't be too repetitive, limit it to 1 exclamation mark, maximum 2 if it REALLY works.You can also send your regards or otherwise check in about their partner, their name is #{event.contacts.map { |contact| contact.partner }.join(", ")} If it is helpful, you can find additional notes on the person here: #{event.contacts.map { |contact| contact.how_met }.join(", ")} ; #{event.contacts.map { |contact| contact.notes }.join(", ")}. The user can also enter additional content on that particular interaction (which you should prioritize incorporating in your response) here: #{user_content}."
    },
    {
      "role" => "user",
      "content" => user_content
    }
  ]
  response = client.chat(
    parameters: {
      model: "gpt-3.5-turbo",
      messages: message_list
    }
  )
  response.dig("choices", 0, "message", "content")
  Rails.logger.debug "API Response: #{response}"
end

 def create
  @event = Event.new(
    event_type: params.fetch("query_event_type"),
    event_date: params.fetch("query_event_date"),
    event_location: params.fetch("query_event_location"),
    intention: params.fetch("query_intention"),
    user_id: params.fetch("query_user_id")
  )
  
  contact_ids = params[:query_contact_ids] || []
  
  if @event.save
    # Create Interaction records only after the event is saved successfully
    contact_ids.each do |contact_id|
      Interaction.create(contact_id: contact_id, event_id: @event.id)
    end
    redirect_to("/events", notice: "Event and interactions created successfully.")
  else
    redirect_to("/events", alert: "Event creation failed: #{@event.errors.full_messages.to_sentence}.")
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
