Rails.application.routes.draw do
  # Routes for the Interaction resource:

  # CREATE
  post("/insert_interaction", { :controller => "interactions", :action => "create" })
          
  # READ
  get("/interactions", { :controller => "interactions", :action => "index" })
  
  get("/interactions/:path_id", { :controller => "interactions", :action => "show" })
  
  # UPDATE
  
  post("/modify_interaction/:path_id", { :controller => "interactions", :action => "update" })
  
  # DELETE
  get("/delete_interaction/:path_id", { :controller => "interactions", :action => "destroy" })

  #------------------------------

  # Routes for the Event resource:

  # CREATE
  post("/insert_event", { :controller => "events", :action => "create" })
          
  # READ
  get("/events", { :controller => "events", :action => "index" })
  
  get("/events/:path_id", { :controller => "events", :action => "show" })
  
  # UPDATE
  
  post("/modify_event/:path_id", { :controller => "events", :action => "update" })
  
  # DELETE
  get("/delete_event/:path_id", { :controller => "events", :action => "destroy" })

  #------------------------------

  # Routes for the Contact resource:

  # CREATE
  post("/insert_contact", { :controller => "contacts", :action => "create" })
          
  # READ
  get("/contacts", { :controller => "contacts", :action => "index" })
  
  get("/contacts/:path_id", { :controller => "contacts", :action => "show" })
  
  # UPDATE
  
  post("/modify_contact/:path_id", { :controller => "contacts", :action => "update" })
  
  # DELETE
  get("/delete_contact/:path_id", { :controller => "contacts", :action => "destroy" })

  #------------------------------

  # Routes for the User resource:

  # CREATE
  post("/insert_user", { :controller => "users", :action => "create" })
          
  # READ
  get("/users", { :controller => "users", :action => "index" })
  
  get("/users/:path_id", { :controller => "users", :action => "show" })
  
  # UPDATE
  
  post("/modify_user/:path_id", { :controller => "users", :action => "update" })
  
  # DELETE
  get("/delete_user/:path_id", { :controller => "users", :action => "destroy" })

  #------------------------------

root "boards#index"

  # This is a blank app! Pick your first screen, build out the RCAV, and go from there. E.g.:

  # get "/your_first_screen" => "pages#first"
  
end
