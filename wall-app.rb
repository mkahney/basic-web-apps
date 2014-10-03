require "sinatra"     # Load the Sinatra web framework
require "data_mapper" # Load the DataMapper database library

require "./database_setup"

class Message
  include DataMapper::Resource

  
  property :comment,    Text, required: false
  property :like,       Integer, required:true, default:0
  property :dislike,    Integer, required: true, default:0
  property :id,         Serial
  property :body,       Text,     required: true
  property :created_at, DateTime, required: true
  
  def total_likes
    self.like - self.dislike
  end
end

DataMapper.finalize()
DataMapper.auto_upgrade!()

get("/") do
  records = Message.all
  records = records.sort_by(&:total_likes).reverse
   
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
  message.comment = params["comment"]
  

  if message.save
    redirect("/")
  else
    body("Something went terribly wrong!")
  end
end

post("/messages/*/dislikes") do |message_id|
  message = Message.get(message_id)
  message.dislike=message.dislike+1
  

  if message.save
    redirect("/")
  else
    body("Something went terribly wrong!")
  end
end

post("/messages/*/likes") do |message_id|
  message = Message.get(message_id)
  message.like=message.like+1
  

  if message.save
    redirect("/")
  else
    body("Something went terribly wrong!")
  end
end