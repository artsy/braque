$LOAD_PATH.push File.expand_path('../lib', __FILE__)

# Maintain your gem's version:
require 'braque/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = 'braque'
  s.version     = Braque::VERSION
  s.authors     = ['Dylan Fareed']
  s.email       = ['email@dylanfareed.com']
  s.homepage    = 'https://github.com/dylanfareed/braque'
  s.summary     = 'Braque provides a simple interface for interacting with Hypermedia API services in Ruby apps.'
  s.description = 'Braque provides a simple interface for interacting with Hypermedia API services in Ruby apps.'
  s.license     = 'MIT'

  s.files = Dir['{lib,spec}/**/*', 'MIT-LICENSE', 'README.md']

  s.add_dependency 'hyperclient'
  s.add_dependency 'active_attr'
  s.add_dependency 'activesupport', '>= 4.2'
end
