class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  skip_forgery_protection
  def index
    @list_of_events = Event.where("event_date >= ?", Date.today).order(event_date: :asc)
    render template: "index"
  end  
  
end
