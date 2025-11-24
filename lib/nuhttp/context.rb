# frozen_string_literal: true

module NuHttp
  class Context
    def initialize(req:, route:)
      @req = req
      @res = Response.new

      @json_loaded = false
    end

    def req #: NuHttp::Request
      @req
    end

    def res #: NuHttp::Response
      @res
    end

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
