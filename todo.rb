require "sinatra"
require "sinatra/reloader"
require "tilt/erubis" # ERB templates



get "/lists" do
  @list = [
    {name: "Lunch Groceries", todos: []},
    {name: "Dinner Groceries", todos: []}
  ]
  erb :lists, layout: :layout
end

get "/" do
  redirect "/lists"
end
