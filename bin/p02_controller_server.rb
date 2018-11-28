require 'rack'
require_relative '../lib/controller_base'

class MyController < ControllerBase
  def go
    if req.path == "/cats"
      render_content("hello cats!", "text/html")
    else
      redirect_to("/cats")
    end
  end
end
app = Proc.new do |env|
  req = Rack::Request.new(env)
  res = Rack::Response.new
  MyController.new(req, res).go
  res.finish
end

Rack::Server.start(
  app: app,
  Port: 3000
)

def render_content(content, content_type)
  res['Content-Type'] = content_type
  res.write(content)
  @already_built_response = true
end

def redirect_to
  self.location =  ("/cats")
  self.status = "302"
end
