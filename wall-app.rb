require "sinatra"     # Load the Sinatra web framework
require "data_mapper" # Load the DataMapper database library

require "./database_setup"
require "./photo_uploader"

# More info at http://datamapper.org/docs/
class Message
  include DataMapper::Resource

  property :id,         Serial
  property :like,       Integer, required:true, default:0
  property :dislike,    Integer, required: true, default:0
  property :body,       Text
  property :created_at, DateTime, required: true

  mount_uploader :photo,   PhotoUploader

  has n, :comments

  def total_likes
    self.like - self.dislike
  end
  
  def has_photo?
    self[:photo] != nil
  end
end

# needs tp belong to user who posted it and users's wall

class User
  include DataMapper::Resource
  
  property :id,               Serial 
  property :background_color, Text, required: false
  property :username,         Text, required: true
  property :password,         Text, required: true
  property :profile_picture,  Text
  property :status,           Text

end
  
class Comment
  include DataMapper::Resource
 
  property :id,           Serial
  property :body,         Text
  property :created_at,   DateTime

  belongs_to :message
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
  message_params = params[:message]
  
  if message_params[:body] == ""
    message_params[:body] = nil
  end
  
  if message_params[:photo] == ""
    message_params[:photo] = nil
  end
  
  message_params[:created_at] = DateTime.now

  message = Message.create(message_params)

  if message.saved?
    redirect("/")
  else
    erb(:error)
  end
end

post("/messages/*/comments") do |message_id|
  message = Message.get(message_id)
 
  comment = Comment.new
  comment.body = params["comment_body"]
  comment.created_at = DateTime.now
 
  message.comments.push(comment)
  message.save
 
  redirect("/")
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

post("/messages/*/destroy") do |message_id|
  message = Message.get(message_id)
  body(message)
  
  # Not sure why we need to use destroy! instead of destroy here
  if message.destroy!
    redirect("/")
  else
    body("Something went terribly wrong!")
  end
end


post("/login") do
  login_params = params[:login]
  puts login_params
  email = login_params[:username]

  if User.count(:username=>email) == 0
    redirect("/unauthorized")
  else 
    redirect("/GOOD")
  end
end