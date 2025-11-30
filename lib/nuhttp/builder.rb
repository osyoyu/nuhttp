# frozen_string_literal: true
# rbs_inline: enabled

module NuHttp
  class Builder
    def initialize(ractor_compat: false)
      @router = Router.new
      @ractor_compat = ractor_compat
    end

    def build
      if @ractor_compat
        @router.routes.freeze
        Ractor.make_shareable @router
        raise if !Ractor.shareable?(@router)
      end
      App.new(@router).tap do |app|
        app.freeze if @ractor_compat
      end
    end

    # The `nuhttp-typegen` tool can be used to generated RBS type signatures
    # tailored for each app.
    # @rbs skip
    def get(path, &block)
      if @ractor_compat
        shareable_block = Ractor.shareable_proc(&block)
        @router.register_route(:get, path, &shareable_block)
      else
        @router.register_route(:get, path, &block)
      end
    end

    # The `nuhttp-typegen` tool can be used to generated RBS type signatures
    # tailored for each app.
    # @rbs skip
    def post(path, &block)
      if @ractor_compat
        shareable_block = Ractor.shareable_proc(&block)
        @router.register_route(:post, path, &shareable_block)
      else
        @router.register_route(:post, path, &block)
      end
    end

    #: (String, NuHttp::App) -> void
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
