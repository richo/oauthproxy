require 'socket'
require 'thread'

module OauthProxy
  class Worker

    def run
      server = TCPServer.new 2000
      loop do
        Thread.start(server.accept) {|client| handle(client)}
      end
    end

    def handle(s)
      req = Request.new
      id = ::OauthProxy.remember(req)
      # Writes 128 bytes
      s.print(id)
      # Bind until we're done here- work out how to poll effciently
      ret = req.q.deq
      # Writes 20 bytes
      s.print(ret)
    ensure
      ::OauthProxy.forget(id)
      s.close
    end
  end

  class Request

    def initialize
      @q = Queue.new
    end

    attr_accessor :oauth_token, :oauth_token_secret
    attr_reader :q

  end

end
