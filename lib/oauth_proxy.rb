require 'uuid'
require 'sinatra/base'

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

      OauthProxy.tokens[params['slug']] = params['code']
      "Ideally, your oauth app should now be configured. Enjoy!"
    end

    get '/tokens/:slug' do
      # Need to verify that we're the original user in some way as well. IP
      # based would make sense?
      unless OauthProxy.tokens.include?(params['slug'])
        halt 404, "Slug not found"
      end

      # TODO Block on the request for the slug
      OauthProxy.tokens.include?(params['slug'])
    end

    get '/' do
      "Rawr at index!"
    end
  end
end
