require File.join(File.dirname(__FILE__), 'lib', 'oauth_proxy')
require File.join(File.dirname(__FILE__), 'lib', 'worker')

Thread.new do
  OauthProxy::Worker.new.run
end

run OauthProxy::App
