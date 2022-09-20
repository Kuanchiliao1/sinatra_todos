require "sinatra"
require "sinatra/reloader"
require "tilt/erubis" # ERB templates

configure do
  enable :sessions # Activate Sinatra's session support
  set :session_secret, 'secret' # If not specific, Sinatra will create random secret everytime it starts
end

# This block is ran before each request is handled
before do
  # Allows the rest of our code to assume session exists
  session[:lists] ||= [] 
end

# View list of lists
get "/lists" do
  @list = session[:lists]
  erb :lists, layout: :layout
end

get "/" do
  redirect "/lists"
end

# Render the new list form
get "/lists/new" do
  erb :new_list, layout: :layout
end

# Create a new list
post "/lists" do
  session[:lists] << {name: params[:list_name], todos: []}
  session[:success] = "The list has been created."
  redirect "/lists"
end