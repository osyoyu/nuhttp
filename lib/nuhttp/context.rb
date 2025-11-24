# frozen_string_literal: true
# rbs_inline: enabled

module NuHttp
  class Context
    def initialize(req:, route:)
      @req = req
      @res = Response.new

      @herb_renderer_loaded = false
      @json_loaded = false
    end

    def req #: NuHttp::Request
      @req
    end

    def res #: NuHttp::Response
      @res
    end

    # TODO: take IO and allow streaming
    def body(str)
      res.body = str
    end

    # Set response to HTML `str`.
    # Content-Type header will be set to `text/html; charset=utf-8`.
    #: (String) -> void
    def html(str)
      res.headers['Content-Type'] = 'text/html; charset=utf-8'
      res.body = str
    end

    # Render a template using the provided renderer and set as HTML response.
    #: (String, ?Hash[Symbol, untyped]) -> void
    def erb(template_path, locals = {})
      require_relative './herb_renderer' if !@herb_renderer_loaded

      rendered = HerbRenderer.new.render(template_path, locals)
      html(rendered)
    end

    # Set response to plain text `str`.
    # Content-Type header will be set to `text/plain; charset=utf-8`.
    #: (String) -> void
    def text(str)
      res.headers['Content-Type'] = 'text/plain; charset=utf-8'
      res.body = str
    end

    # Set response to the JSON representation of `obj`.
    # Content-Type header will be set to `application/json`.
    #: (Object) -> void
    def json(obj)
      require 'json' if !@json_loaded

      res.headers['Content-Type'] = 'application/json'
      res.body = JSON.generate(obj)
    end
  end

  class Request
    attr_reader :method, :path, :query, :headers, :body
    attr_accessor :params

    def initialize(method:, path:, query:, body:)
      @method = method
      @path = path
      @query = query

      @headers = {}
      @body = body

      @params = {}
    end
  end

  class Response
    attr_accessor :status, :headers, :body

    def initialize
      @status = 200
      @headers = {}
      @body = ""
    end
  end
end
