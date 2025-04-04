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
    Rails.logger.debug "params[:query_contact_ids] = #{params[:query_contact_ids].inspect}"

    render({ :template => "events/index" })
  end

  def show
    the_id = params.fetch("path_id")
    @the_event = Event.find_by(id: params[:path_id])
    
    if params[:user_content].present?
      # Generate new email from user content
      @email = generate_email(@the_event, params[:user_content])
      
      # Store in session
      session[:generated_email] = @email
      
      # Redirect with flag
      Rails.logger.debug "params[:query_contact_ids] = #{params[:query_contact_ids].inspect}"
      Rails.logger.debug "Generated email: #{@email.inspect}"

      redirect_to url_for(controller: "events", action: "show", id: @the_event.id, email_generated: true) and return
      
    end
    
    # Load from session if we're looking at the generated email
    @email = session[:generated_email] if params[:email_generated]
    
    if @the_event
      @all_contacts = Contact.all
    else
      redirect_to(events_path, alert: "Event not found.")
    end

    render({ template: "events/show" })
  end

  def generate_email(event, user_content)
    return "Thank you for taking the time to meet with me on #{event.event_date}" if user_content.blank?
  
    client = OpenAI::Client.new(access_token: ENV.fetch("OPENAI_API_KEY"), request: { timeout: 60, headers: { "Custom-Header" => "value" } })
    response = client.chat(
      parameters: {
        model: "gpt-3.5-turbo",
        messages: [
          {
            "role" => "system",
            "content" => "Draft a thank you email after networking with someone. You met with them on #{event.event_date} via a format of #{event.event_type}, their name is #{event.contacts.map { |contact| "#{contact.first_name} #{contact.last_name}" }.join(", ")}. The user will input some takeaways from the meeting. You want the tone to be friendly, but professional, acknowledging the user is likely not very close with the person. Emphasize WARMTH coming across. Keep it under one paragraph. Do NOT give them any fill in the blanks in the email. Try to write something generic about having learned a lot or gained a new perspective if they don't include notes. But DO NOT make it too obvious that it's generic, try to sound as thoughtful and personal as possible. Do not try to kiss up to them, and limit any words that are three syllables or longer. Avoid corporate speak -- do NOT say phrases such as 'valuable insights', 'crossing paths', etc but don't make it too informal. For an example on the level of formality -- phrases like 'I wanted to express my gratitude' are too formal and should NOT be used, opt for phrases like 'I am grateful for' instead. Meanwhile, phrases like 'Looking forward to staying in touch' should NOT be used; instead use 'I look forward to staying in touch' or 'I hope to stay in touch'. Try to find a happy medium between both examples in the general messaging. It should be 4-7 sentences long. Reference the date of the interaction (as inputted by the user). Don't be too repetitive, and limit it to 1 exclamation mark (maximum 2 if it REALLY works). You can also send your regards or otherwise check in about their partner, whose name is #{event.contacts.map { |contact| contact.partner }.join(", ")}. If it is helpful, you can find additional notes on the person here: #{event.contacts.map { |contact| contact.how_met }.join(", ")}; #{event.contacts.map { |contact| contact.notes }.join(", ")}. The user can also enter additional content on that particular interaction (which you should prioritize incorporating in your response) here: #{user_content}"
          }
        ]
      }
    )
  
    generated_email = response["choices"]&.first&.dig("message", "content")
    Rails.logger.debug "Generated Email: #{generated_email}"
    return generated_email
  rescue => e
    Rails.logger.error "OpenAI API Error: #{e.message}"
    return "Error generating email: #{e.message}"
  end
  

  
 def create
  @event = Event.new(
    event_type: params.fetch("query_event_type"),
    event_date: params.fetch("query_event_date"),
    event_location: params.fetch("query_event_location"),
    intention: params.fetch("query_intention"),
    user_id: params.fetch("query_user_id")
  )
  
  contact_ids = Array(params[:query_contact_ids])


  if @event.save
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
    the_event.contacts = Contact.where(id: contact_ids) 
    

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
