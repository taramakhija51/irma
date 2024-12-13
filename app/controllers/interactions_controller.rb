class InteractionsController < ApplicationController
  def index
    matching_interactions = Interaction.all

    @list_of_interactions = matching_interactions.order({ :created_at => :desc })

    render({ :template => "interactions/index" })
  end

  def show
    the_id = params.fetch("path_id")
    @the_contact = Contact.find_by(id: the_id, user_id: current_user.id)
    the_id = params.fetch("path_id")

    matching_interactions = Interaction.where({ :id => the_id })

    @the_interaction = matching_interactions.at(0)


    render({ :template => "interactions/show" })
  end

  def create
    @event = Event.new
    #@event.id = params.fetch("query_event_id")
  
    if @event.save
      contact_ids = params.fetch("query_contact_id")
      #contact_ids = @the_contact.id
      contact_ids.each do |contact_id|
        Interaction.create(:contact_id => contact_id, :event_id => @event.id)
      end
      redirect_to("/events", { :notice => "Event and interactions created successfully." })
    else
   p "not created successfully"
    end
  end
  

  def update
    the_id = params.fetch("path_id")
    the_interaction = Interaction.where({ :id => the_id }).at(0)

    the_interaction.contact_id = params.fetch("query_contact_id")
    the_interaction.event_id = params.fetch("query_event_id")

    if the_interaction.valid?
      the_interaction.save
      redirect_to("/interactions/#{the_interaction.id}", { :notice => "Interaction updated successfully."} )
    else
      redirect_to("/interactions/#{the_interaction.id}", { :alert => the_interaction.errors.full_messages.to_sentence })
    end
  end

  def destroy
    the_id = params.fetch("path_id")
    the_interaction = Interaction.where({ :id => the_id }).at(0)

    the_interaction.destroy

    redirect_to("/interactions", { :notice => "Interaction deleted successfully."} )
  end


end
