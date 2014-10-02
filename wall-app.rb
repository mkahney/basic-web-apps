require "sinatra"     # Load the Sinatra web framework
require "data_mapper" # Load the DataMapper database library

require "./database_setup"

class Message
  include DataMapper::Resource

  
  property :comment,    Text, required: false
  property :id,         Serial
  property :body,       Text,     required: true
  property :created_at, DateTime, required: true
end

DataMapper.finalize()
DataMapper.auto_upgrade!()

get("/") do
  records = Message.all(order: :created_at.desc)
  erb(:index, locals: { messages: records })
end
get '/message' do
  message_id=params["id"]
  message = Message.first(id: message_id)
  message.body
end
post("/messages") do
  message_body = params["body"]
  message_time = DateTime.now


  message = Message.create(body: message_body, created_at: message_time)


  if message.saved?
    redirect("/")
  else
    erb(:error)
  end
end

post("/messages/*/comments") do |message_id|
  message = Message.get(message_id)
  message.comment1 = params["comment"]
  message.comment2 = params["comment"]
  message.comment3 = params["comment"]
  message.comment4 = params["comment"]
  

  if message.save
    redirect("/")
  else
    body("Something went terribly wrong!")
  end
end
