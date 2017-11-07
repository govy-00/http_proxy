require "./server/handler"
require "./server/response"

module HTTP
  # :nodoc:
  module Proxy
    class Server
      getter :host, :port

      def initialize(@host = "127.0.0.1", @port = 8080)
        handler = build_middleware
        @processor = RequestProcessor.new(handler)
      end

      def initialize(@host = "127.0.0.1", @port = 8080, &handler : Handler::Proc)
        handler = build_middleware(handler)
        @processor = RequestProcessor.new(handler)
      end

      def initialize(@host = "127.0.0.1", @port = 8080, *, handlers : Array(HTTP::Handler), &handler : Handler::Proc)
        handler = build_middleware(handlers, handler)
        @processor = RequestProcessor.new(handler)
      end

      def initialize(@host = "127.0.0.1", @port = 8080, *, handlers : Array(HTTP::Handler))
        handler = build_middleware(handlers)
        @processor = RequestProcessor.new(handler)
      end

      def initialize(@host = "127.0.0.1", @port = 8080, *, handler : HTTP::Handler | Handler::Proc)
        handler = build_middleware(handler)
        @processor = RequestProcessor.new(handler)
      end

      private def build_middleware(handler : Handler::Proc? = nil)
        proxy_handler = Handler.new
        proxy_handler.next = handler if handler
        proxy_handler
      end

      private def build_middleware(handlers, last_handler : Handler::Proc? = nil)
        proxy_handler = build_middleware(last_handler)
        return proxy_handler if handlers.empty?

        handlers.each_cons(2) do |group|
          group[0].next = group[1]
        end
        handlers.last.next = proxy_handler if proxy_handler

        handlers.first
      end
    end
  end
end
