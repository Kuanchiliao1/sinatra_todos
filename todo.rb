require "sinatra"
require "sinatra/reloader"
require "tilt/erubis" # ERB templates



get "/" do
  @list = [
    {name: "Lunch Groceries"},
    {name: "Dinner Groceries"}
  ]
  erb :lists, layout: :layout
end
