require File.join(File.dirname(__FILE__), 'lib', 'oauth_proxy')
require File.join(File.dirname(__FILE__), 'lib', 'worker')
require File.join(File.dirname(__FILE__), 'lib', 'config')

Thread.new do
  OauthProxy::Worker.new.run
end

run OauthProxy::App
