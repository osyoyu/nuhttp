# frozen_string_literal: true

module NuHttp
  class Builder
    def initialize
      @router = Router.new
    end

    def build
      App.new(@router)
    end

    # @rbs &block: (Context) -> void
    def get(path, &block)
      @router.register_route(:get, path, &block)
    end

    # @rbs &block: (Context) -> void
    def post(path, &block)
      @router.register_route(:post, path, &block)
    end

    # @rbs &block: (App) -> void
    def mount(path, subapp)
      subapp.routes.each do |route|
        @router.register_route(
          route.method,
          path + route.pattern,
          &route.handler
        )
      end
    end
  end
end
