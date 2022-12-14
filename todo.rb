require "sinatra"
require "sinatra/reloader"
require "sinatra/content_for"
require "tilt/erubis" # ERB templates
require "pry"

# Test heroku1

configure do
  enable :sessions 
  set :session_secret, 'secret' # If not specific, Sinatra will create random secret everytime it starts
end

# These methods are accessible in ANY view templates AND in this file
# Try not to put methods that aren't intended for use in template in here
helpers do 
  def list_complete?(list)
    list[:todos].size > 0 && list[:todos].all? { |todo| todo[:completed] }
  end

  def list_class(list)
    "complete" if list_complete?(list)
  end

  def todos_count(list)
    list[:todos].size
  end

  def todos_remaining_count(list)
    list[:todos].count do | hash |
      hash[:completed] = "complete"
    end
  end
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
  @list_id = params[:id].to_i
  @list = session[:lists][@list_id]
  erb :list, layout: :layout
end

# Edit an existing todo list
get "/lists/:id/edit" do
  id = params[:id].to_i
  @list = session[:lists][id]
  erb :list_edit
end

# Delete a todo from list
post "/lists/:list_id/todos/:todo_id/destroy" do
  @list_id = params[:list_id].to_i
  @list = session[:lists][@list_id]
  
  todo_id = params[:todo_id].to_i
  @list[:todos].delete_at(todo_id)
  session[:success] = "The todo has been deleted."
  redirect "/lists/#{@list_id}"
end

# Delete the todo list
post "/lists/:id/destroy" do
  binding.pry
  id = params[:id].to_i
  session[:lists].delete_at(id)
  session[:success] = "The list has been deleted"
  redirect "/lists"
end

# Update status of todo
post "/lists/:list_id/todos/:todo_id" do
  @list_id = params[:list_id].to_i
  @list = session[:lists][@list_id]
  
  todo_id = params[:todo_id].to_i
  is_completed = params[:completed] == "true"
  @list[:todos][todo_id][:completed] = is_completed
  session[:success] = "The todo has been updated."
  redirect "/lists/#{@list_id}"
end

# Mark all todos complete for a list
post "/lists/:list_id/complete_all" do
  @list_id = params[:list_id].to_i
  @list = session[:lists][@list_id]

  @list[:todos].each {|hash| hash[:completed] = true}
  session[:success] = "All todos have been completed."
  redirect "/lists/#{@list_id}"
end

# Add new todo to list
post "/lists/:list_id/todos" do
  @list_id = params[:id].to_i
  @list = session[:lists][@list_id]
  text = params[:todo].strip

  error = error_for_todos(text)
  if error
    session[:error] =  error
    erb :list, layout: :layout
  else
    @list[:todos] << {name: text, completed: false}
    session[:success] = "The todo was added."
    redirect "/lists/#{@list_id}"
  end
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

# Return an error msg if name is invalid. Return nil if name is valid.
def error_for_todos(name)
  if !(1..100).cover? name.size
    "Todo must be between 1 and 100 chars."
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

