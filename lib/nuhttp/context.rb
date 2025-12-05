# frozen_string_literal: true
# rbs_inline: enabled

module NuHttp
  # @rbs generic ParamsT
  class Context
    def initialize(req:, route:)
      @req = req
      @res = Response.new

      @json_loaded = false
    end

    def req #: Request[ParamsT]
      @req
    end

    def res #: Response
      @res
    end

    def status(code)
      res.status = code
    end

    def header(name, value)
      res.headers[name] = value
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

  # @rbs generic ParamsT
  class Request
    attr_reader :method, :path, :query, :headers, :body
    attr_accessor :params #: ParamsT

    def initialize(method:, path:, query:, headers: {}, body:)
      @method = method
      @path = path
      @query = query

      @headers = headers
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
