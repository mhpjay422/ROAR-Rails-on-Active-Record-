class Route
  attr_reader :pattern, :http_method, :controller_class, :action_name

  def initialize(pattern, http_method, controller_class, action_name)
    @pattern = pattern
    @http_method = http_method
    @controller_class = controller_class
    @action_name = action_name
  end

  def matches?(req)
    (@pattern =~ req.path) && (@http_method.to_s.upcase == req.request_method)
  end

  def run(req, res)
    matched_data = @pattern.match(req.path)
    route_params = Hash[matched_data.names.zip(matched_data.captures)]
    new_inst = @controller_class.new(req, res, route_params)
    new_inst.invoke_action(@action_name)
  end
end

class Router
  attr_reader :routes

  def initialize
    @routes = []
  end

  def add_route(pattern, method, controller_class, action_name)
    @routes << Route.new(pattern, method, controller_class, action_name)
  end

  def draw(&proc)
    self.instance_eval(&proc)
  end

  [:get, :post, :put, :delete].each do |http_method|
    define_method(http_method) do |pattern, controller_class, action_name|
      add_route(pattern, http_method, controller_class, action_name)
    end
  end


  def match(req)
    routes.find { |route| route.matches?(req)}
  end

  def run(req, res)
    route_match = self.match(req)
    route_match.nil? ? res.status = 404 : route_match.run(req, res)
  end
end
