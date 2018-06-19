# nancy.rb
require "rack"

module Nancy
  class Base
    def initialize
      @routes = {}
    end

    attr_reader :routes

    def get(path, &handler)
      route("GET", path, &handler)
    end

    def call(env)
      @request = Rack::Request.new(env)
      verb = @request.request_method
      requested_path = @request.path_info

      handler = @routes.fetch(verb, {}).fetch(requested_path, nil)

      if handler
        # handler.call
        instance_eval(&handler)
      else
        [404, {}, ["Oops! No route for #{verb} #{requested_path}"]]
      end
    end

    private

    def route(verb, path, &handler)
      @routes[verb] ||= {}
      @routes[verb][path] = handler
    end

    def params
      @request.params
    end
  end
end

nancy = Nancy::Base.new

nancy.get "/hello" do
  [200, {}, ["Nancy says hello"]]
end

Rack::Handler::WEBrick.run nancy, Port: 9292

puts nancy.routes
