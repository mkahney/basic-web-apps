require "sinatra"     # Load the Sinatra web framework

header_style = "style='color:red;font-family:Times, Georgia;font-size:70pt;'"

get("/") do
  html = ""
  html.concat("<h1 #{header_style}>Message of The Day</h1>")
  html.concat("<a href='/message'>See today's message.</a>")

  body(html)
end

get("/message") do
  file_contents = File.read("message-of-the-day.txt")

  html = ""
  html.concat("<h1 #{header_style}>Message of The Day</h1>")
  html.concat("<p>Today's message is: #{file_contents}")

  body(html)
end
