require 'uuid'
require 'sinatra/base'
require 'timeout'

module OauthProxy
  extend self

  @uuid = UUID.new

  attr_reader :callbacks, :tokens

  @callbacks = {}
  @tokens = {}

  def remember(v)
    id = @uuid.generate
    @callbacks[id] = v

    return id
  end

  def forget(k)
    @callbacks.delete(k)
  end

  class App < Sinatra::Base
    get '/callback/:slug' do
      unless OauthProxy.callbacks.include?(params['slug'])
        halt 404, "Slug not found"
      end

      OauthProxy.callbacks[params['slug']].q.enq params['code']
      "Ideally, your oauth app should now be configured. Enjoy!"
    end

    get '/tokens/:slug' do
      slug = params['slug']
      # Need to verify that we're the original user in some way as well. IP
      # based would make sense?
      unless OauthProxy.callbacks.include?(params['slug'])
        halt 404, "Slug not found"
      end

      # Race conditions abound
      callback = OauthProxy.callbacks[slug]
      OauthProxy.reject! { |n| n == slug }

      # Control returns here.. Shit.
      Thread.start(callback) do |callback|
        begin
          Timeout::timeout(15) {
            return callback.q.deq
          }
        rescue Timeout::Error
          # TODO Retry-After header
          halt 504, "Upstream did not reply in an orderly fashion"
        end
      end
    end

    get '/' do
      "Rawr at index!"
    end
  end
end
