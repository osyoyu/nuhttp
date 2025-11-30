# frozen_string_literal: true
# rbs_inline: enabled

require 'socket'

module NuHttp
  class Server
    # @rbs skip
    include Socket::Constants

    RFC9110_REASON_PHRASES = {
      100 => "Continue",
      101 => "Switching Protocols",
      200 => "OK",
      201 => "Created",
      202 => "Accepted",
      203 => "Non-Authoritative Information",
      204 => "No Content",
      205 => "Reset Content",
      206 => "Partial Content",
      300 => "Multiple Choices",
      301 => "Moved Permanently",
      302 => "Found",
      303 => "See Other",
      304 => "Not Modified",
      305 => "Use Proxy",
      307 => "Temporary Redirect",
      308 => "Permanent Redirect",
      400 => "Bad Request",
      401 => "Unauthorized",
      402 => "Payment Required",
      403 => "Forbidden",
      404 => "Not Found",
      405 => "Method Not Allowed",
      406 => "Not Acceptable",
      407 => "Proxy Authentication Required",
      408 => "Request Timeout",
      409 => "Conflict",
      410 => "Gone",
      411 => "Length Required",
      412 => "Precondition Failed",
      413 => "Content Too Large",
      414 => "URI Too Long",
      415 => "Unsupported Media Type",
      416 => "Range Not Satisfiable",
      417 => "Expectation Failed",
      421 => "Misdirected Request",
      422 => "Unprocessable Content",
      426 => "Upgrade Required",
      500 => "Internal Server Error",
      501 => "Not Implemented",
      502 => "Bad Gateway",
      503 => "Service Unavailable",
      504 => "Gateway Timeout",
      505 => "HTTP Version Not Supported",
    }.freeze

    def initialize(app, bind: "127.0.0.1", port: 8080, ractor_mode: false, call_make_shareable: false)
      @app = app
      @bind_address = bind
      @port = port
      @ractor_mode = ractor_mode

      # When app_make_shareable: true, app will be deep frozen in attempt to
      # make it Ractor shareable.
      # Note: the app may not be made shareable, even if this option is specified.
      Ractor.make_shareable(@app) if call_make_shareable
      raise "app is not shareable" if @ractor_mode && !Ractor.shareable?(@app)
    end

    def start
      socket = Socket.new(AF_INET, SOCK_STREAM, 0)
      socket.setsockopt(SOL_SOCKET, SO_REUSEADDR, true)
      sockaddr = Socket.pack_sockaddr_in(@port, @bind_address)
      socket.bind(sockaddr)
      socket.listen(64) # backlog
      puts "Listening on #{@bind_address}:#{@port}"

      loop do
        connn, _ = socket.accept # chose awkward name to avoid shadowing

        if @ractor_mode
          # Make sure @app does not get copied on Ractor.new
          Ractor.new(@app) do |app|
            conn = Ractor.receive
            Server.handle(app, conn)
            nil # reduce implicit copy on #value
          ensure
            conn.close
          end.send(connn, move: true)
        else
          Server.handle(@app, connn)
          connn.close
        end
      end
    ensure
      socket.close if defined?(socket)
    end

    def self.handle(app, conn)
      request = HttpParser.parse_request(conn)

      begin
        res = app.dispatch(request)
      rescue => e
        error_message = [
          "#{e.class}: #{e.message}",
          e.backtrace&.map { |line| "\tfrom #{line}" }&.join("\n")
        ].join("\n")
        puts error_message

        res = Response.new.tap do |r|
          r.status = 500
          r.headers["Content-Type"] = "text/plain"
          r.body = "Internal Server Error\n"
        end
      end

      reason_phrase = RFC9110_REASON_PHRASES[res.status] || "Unknown"

      conn.write "HTTP/1.1 #{res.status} #{reason_phrase}\r\n"

      # Send headers
      res.headers.each do |header_name, header_body|
        conn.write "#{header_name}: #{header_body}\r\n"
      end

      chunked = res.headers["Transfer-Encoding"] == "chunked" # ?

      # Send body
      body = res.body
      if !chunked
        body_str = String.new
        body_str << body

        conn.write "Content-Length: #{body_str.bytesize}\r\n"
        conn.write "Connection: Close\r\n" # no keepalive impl (yet)
        conn.write "\r\n"

        conn.write body_str
      else
        conn.write "\r\n"

        body.each do |chunk|
          conn.write chunk.bytesize.to_s(16) + "\r\n"
          conn.write chunk
          conn.write "\r\n"
        end

        conn.write "0" + "\r\n\r\n"
      end
    end

    module HttpParser
      class << self
        def parse_request(io)
          request_line = io.gets("\r\n").chomp
          method, request_target, _http_version = request_line.split(' ', 3)

          headers = {}
          while line = io.gets("\r\n").chomp
          break if line.empty?

            header_name, header_value = line.split(':', 2)
            headers[header_name] = header_value.strip
          end

          path, query = request_target.split('?')
          query ||= ''

          body =
            if length = headers['Content-Length'] # TODO: match any case
              io.read(length.to_i)
            else
              nil
            end


          Request.new(method:, path:, query:, headers:, body:)
        end
      end
    end
  end
end
