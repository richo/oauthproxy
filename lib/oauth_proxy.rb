require 'uuid'
require 'sinatra/base'

module OauthProxy
  extend self

  @uuid = UUID.new

  attr_reader :callbacks

  @callbacks = {}

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
    end

    get '/' do
      "Rawr at index!"
    end
  end
end
