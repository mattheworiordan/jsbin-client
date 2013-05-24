$: << '../lib'
require 'jsbin-client'
require 'webmock'
require 'webmock/rspec'

RSpec.configure do |config|
  # using standard RSpec config
end

WebMock.disable_net_connect!