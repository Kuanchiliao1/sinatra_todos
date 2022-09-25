require "sinatra"
require "sinatra/reloader"
require "sinatra/content_for"
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

# View any individual list
get "/lists/:id" do
  @id = params[:id].to_i
  @list = session[:lists][@id]
  erb :list, layout: :layout
end

# Edit an existing todo list
get "/lists/:id/edit" do
  id = params[:id].to_i
  @list = session[:lists][id]
  erb :list_edit
end

# Delete the todo list
post "/lists/:id/destroy" do
  id = params[:id].to_i
  session[:lists].delete_at(id)
  session[:success] = "The list has been deleted"
  redirect "/lists"
end

# Updating an existing todo list
post "/lists/:id" do
  list_name = params[:list_name].strip
  id = params[:id].to_i
  @list = session[:lists][id]

  error = error_for_list_name(list_name)
  if error
    session[:error] = error
    erb :list_edit, layout: :layout
  else
    @list[:name] = list_name
    session[:success] = "The list has been updated."
    redirect "/lists/#{id}"
  end
end

# Return an error msg if name is invalid. Return nil if name is valid.
def error_for_list_name(name)
  if !(1..100).cover? name.size
    "List name must be between 1 and 100 chars."
  elsif session[:lists].any? {|list| list[:name] == name }
    "List name must be unique."
  end
end

# Create a new list
post "/lists" do
  list_name = params[:list_name].strip

  error = error_for_list_name(list_name)
  if error
    session[:error] = error
    erb :new_list, layout: :layout
  else
    session[:lists] << {name: list_name, todos: []}
    session[:success] = "The list has been created."
    redirect "/lists"
  end
end

