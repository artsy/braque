$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

Dir["#{File.dirname(__FILE__)}/shared/**/*.rb"].each do |file|
  require file
end

Dir["#{File.dirname(__FILE__)}/fixtures/**/*.rb"].each do |file|
  require file
end

# Require library up front
require 'braque'
require 'webmock/rspec'
require 'byebug'
