require "sinatra"     # Load the Sinatra web framework

get("/") do
  html = ""

  html.concat("<h1>Hello, World!</h1>")
  html.concat("<ul>")
  html.concat("<li><a href='/waffles'>show me waffles</a></li>")
  html.concat("<li><a href='/waffles/chocolate'>show me chocolate</a></li>")
  html.concat("<li><a href='/bake?baked_good=cookies&count=10'>bake 10 cookies</a></li>")
  html.concat("<li><a href='/bake?baked_good=cronut&count=5'>bake 5 cronuts</a></li>")
  html.concat("<li><a href='/bake?baked_good=cupcakes&count=1138'>bake 1138 cupcakes</a></li>")
  html.concat("</ul>")

  body(html)
end

get("/giraffe") do
  html = ""

  html.concat("<h1>Giraffes are delicious.</h1>")
    html.concat("<h1>Dinosour are delicious.</h1>")
  html.concat("<h1>Giraffes are delicious.</h1>")
  html.concat("<h1>Giraffes are delicious.</h1>")


  body(html)
end

get("/waffles/chocolate") do
  html = ""

  html.concat("<h1>Chocolate waffles: more delicious.</h1>")
  html.concat("<p>Do you not believe me?!</p>")
  html.concat("<a href='/'>return</a>")
  body(html)
end

# Visit, e.g., /bake?baked_good=waffles&count=20
get("/bake") do
  count      = Integer(params["count"])
  baked_good = String(params["baked_good"])

  html = "I'm going to bake #{count} #{baked_good}!"

  html.concat("<ul>")
  count.times do |num|
    html.concat("<li>#{baked_good} number #{num}</li>")
  end
  html.concat("</ul>")

  body(html)
end
