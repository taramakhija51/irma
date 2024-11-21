class InteractionsController < ApplicationController
  def index
    matching_interactions = Interaction.all

    @list_of_interactions = matching_interactions.order({ :created_at => :desc })

    render({ :template => "interactions/index" })
  end

  def show
    the_id = params.fetch("path_id")

    matching_interactions = Interaction.where({ :id => the_id })

    @the_interaction = matching_interactions.at(0)

    render({ :template => "interactions/show" })
  end

  def create
    the_interaction = Interaction.new
    the_interaction.contact_id = params.fetch("query_contact_id")
    the_interaction.event_id = params.fetch("query_event_id")

    if the_interaction.valid?
      the_interaction.save
      redirect_to("/interactions", { :notice => "Interaction created successfully." })
    else
      redirect_to("/interactions", { :alert => the_interaction.errors.full_messages.to_sentence })
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

  belongs_to(:event,
    class_name: "Event",
    foreign_key: "event_id"
  )

  belongs_to(:contact,
  class_name: "Contact",
  foreign_key: "contact_id"
)
end
