# frozen_string_literal: true

require 'rack'

module NuHttp
  class RackPort
    def initialize(app)
      @app = app
    end

    def call(env)
      method = env['REQUEST_METHOD']
      path = env['PATH_INFO'] || '/'
      query = env['QUERY_STRING'] || ''

      req = Request.new(method:, path:, query:, body: '')
      res = @app.dispatch(req)

      [res.status, {}, [res.body]]
    end
  end
end
