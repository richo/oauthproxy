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
      s.puts("#{id} Added to queue")
      # Bind until we're done here- work out how to poll effciently
      req.q.deq
      s.puts("#{id} Processed")
      #
      # In the webapp we call req.q.enq :status
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
