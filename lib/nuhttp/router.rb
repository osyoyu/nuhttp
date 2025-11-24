# frozen_string_literal: true

module NuHttp
  class Router
    Route = Data.define(:method, :pattern, :handler)

    NOT_FOUND_ROUTE = Route.new(
      method: :internal,
      pattern: nil,
      handler: proc do |c|
        c.res.status = 404
        c.res.body = "Not Found\n"
      end
    )

    def initialize
      @routes = []
    end

    def routes
      @routes
    end

    # @rbs (Symbol, String) -> void
    def register_route(method, pattern, &block)
      @routes << Route.new(method:, pattern:, handler: block)
    end

    # @rbs (NuHttp::Request) -> [Route, Hash]
    def resolve(req)
      @routes.each do |route|
        # Turn the user supplied pattern into a regexp that captures named params.
        param_names = []
        regexp = /\A#{route.pattern.gsub(/:[^\/]+/) {|segment|
          param_names << segment.delete_prefix(':')
              "([^/]+)"
        }}\z/

        # Test if the request path matches the route pattern
        match = regexp.match(req.path)
        next unless match

        params = {}
        param_names.each.with_index do |name, index|
          params[name.to_sym] = match.captures[index]
        end

        return [route, params]
      end

      # If no route matches, return a fixed 404 response
      [NOT_FOUND_ROUTE, {}]
    end
  end
end
