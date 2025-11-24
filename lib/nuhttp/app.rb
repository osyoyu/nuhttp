# frozen_string_literal: true

module NuHttp
  class App
    def initialize(router)
      @router = router
    end

    # The entrypoint of the request.
    # @rbs (NuHttp::Context) -> void
    def dispatch(req)
      route, params = @router.resolve(req)
      # Create a new Context
      ctx = Context.new(req:, route:)
      # Populate req.params
      req.params = params
      route.handler.call(ctx)
      ctx.res
    end

    def routes
      @router.routes
    end
  end
end
