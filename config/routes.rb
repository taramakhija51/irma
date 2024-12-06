Rails.application.routes.draw do
  devise_for :users
  root "contacts#index"
  # Alias for sign-out

  # Routes for the Interaction resource:
  post("/insert_interaction", { :controller => "interactions", :action => "create" })
  get("/interactions", { :controller => "interactions", :action => "index" })
  get("/interactions/:path_id", { :controller => "interactions", :action => "show" })
  post("/modify_interaction/:path_id", { :controller => "interactions", :action => "update" })
  get("/delete_interaction/:path_id", { :controller => "interactions", :action => "destroy" })

  # Routes for the Event resource:
  post("/insert_event", { :controller => "events", :action => "create" })
  get("/events", { :controller => "events", :action => "index" })
  get("/events/:path_id", { :controller => "events", :action => "show" })
  post("/modify_event/:path_id", { :controller => "events", :action => "update" })
  get("/delete_event/:path_id", { :controller => "events", :action => "destroy" })

  # Routes for the Contact resource:
  post("/insert_contact", { :controller => "contacts", :action => "create" })
  get("/contacts", { :controller => "contacts", :action => "index" })
  get("/contacts/:path_id", { :controller => "contacts", :action => "show" })
  post("/modify_contact/:path_id", { :controller => "contacts", :action => "update" })
  get("/delete_contact/:path_id", { :controller => "contacts", :action => "destroy" })



  
end
