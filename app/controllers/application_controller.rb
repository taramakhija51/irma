class ApplicationController < ActionController::Base
  skip_forgery_protection
  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end
  
end
