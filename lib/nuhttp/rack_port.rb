# frozen_string_literal: true
# rbs_inline: enabled

require 'rack'

module NuHttp
  class RackPort
    def initialize(app)
      @app = app
    end

    def call(env)
      req = env_to_request(env)
      res = @app.dispatch(req)

      [res.status, res.headers, [res.body]]
    end

    private def env_to_request(env)
      method = env['REQUEST_METHOD']
      path = env['PATH_INFO'] || '/'
      query = env['QUERY_STRING'] || ''

      # Extract request headers
      # Racks stores headers in the env with 'HTTP_' prefix, with the
      # exception of Content-Type and Content-Length
      headers = {}
      if env['CONTENT_TYPE']
        headers['Content-Type'] = env['CONTENT_TYPE']
      end
      if env['CONTENT_LENGTH']
        headers['Content-Length'] = env['CONTENT_LENGTH'].to_i
      end
      env.each do |key, value|
        header_name = key.start_with?('HTTP_') ? key[5..].split('_').map(&:capitalize).join('-') : nil
        if header_name
          headers[header_name] = value
        end
      end

      Request.new(method:, path:, query:, headers:, body: '')
    end
  end
end
