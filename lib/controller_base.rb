require 'active_support'
require 'active_support/core_ext'
require 'erb'
require_relative './session'

class ControllerBase
  attr_reader :req, :res, :params

  def initialize(req, res, params = {})
    @req = req
    @res = res
    @params = params.merge(req.params)
  end

  def already_built_response?
    @already_built_response
  end

  def redirect_to(url)
    @res.set_header("Location", url)
    @res.status = 302
    if already_built_response?
      raise "error error"
    end
    session.store_session(@res)
    @already_built_response = true
  end

  def render_content(content, content_type)
    @res["Content-Type"] = content_type
    @res.write(content)
    if already_built_response?
      raise "error error"
    end
    session.store_session(@res)
    @already_built_response = true
  end

  def render(template_name)
    template = File.join("views", self.class.name.underscore, "#{template_name}.html.erb")
    template_read = File.read(template)
    render_content(
      ERB.new(template_read).result(binding),
      "text/html"
    )
  end

  def session
    @session ||= Session.new(@req)

  end

  def invoke_action(name)
    self.send(name)
    render(name) unless already_built_response?
  end
end
