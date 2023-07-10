# frozen_string_literal: true

require 'webmock/rspec'
require 'rspec'
require 'rack/test'
require 'json'

RSpec.configure do |config|
  config.after(:suite) do
    FileUtils.rm_rf(Dir['tmp/*'])
    WebMock.disable_net_connect!(allow_localhost: true)
  end
end
