require "sinatra"     # Load the Sinatra web framework
require "data_mapper" # Load the DataMapper database library

require "./database_setup"
require "./photo_uploader"

# More info at http://datamapper.org/docs/
class Message
  include DataMapper::Resource

  property :like,       Integer, required:true, default:0
  property :dislike,    Integer, required: true, default:0
  property :id,         Serial
  property :body,       Text,     required: true
  property :created_at, DateTime, required: true
  
  def total_likes
    self.like - self.dislike
  end
  has n, :comments
  has 1, :photo
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
  belongs_to :photo
end

class Photo
  include DataMapper::Resource
  
  property :id,             Serial
  mount_uploader :source,   PhotoUploader
  property :likes,          Integer, default:0
  property :dislikes,       Integer, default:0
  
  def total_likes
    self.like - self.dislike
  end
  has n, :comments
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
  message_body = params["body"]
  message_time = DateTime.now


  message = Message.create(body: message_body, created_at: message_time)


  if message.saved?
    redirect("/")
  else
    erb(:error)
  end
end

# post("/messages/*/comments") do |message_id|
#   message = Message.get(message_id)
#   message.comment = params["comment"]
#   # message.comment = "this is a comment"
  

#   if message.save
#   redirect("/")
#   else
#   body("Something went terribly wrong!")
#   end
# end

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

get("/") do
  photos = Photo.all
  erb(:index, :locals => { :photos => photos })
end
 get("/") do
 records = Message.all
 records = records.sort_by(&:total_likes).reverse

get("/photos/new") do
  photo = Photo.new
  erb(:photos_new, :locals => { :photo => photo })
end

get("/photos/*") do |photo_id|
  photo = Photo.get(photo_id)
  erb(:photos_show, :locals => { :photo => photo })
end

post("/photos") do
  photo = Photo.create(params[:photo])

  if photo.saved?
    redirect("/")
  else
    erb(:photos_new, :locals => { :photo => photo })
  end
end

get("/") do
  photos = Photo.all
  erb(:index, :locals => { :photos => photos })
  end
end
