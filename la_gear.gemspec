# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'la_gear/version'

Gem::Specification.new do |spec|
  spec.name          = 'la_gear'
  spec.version       = LaGear::VERSION
  spec.authors       = ['Gabriel Chaney', 'Andy Arminio', 'Jonah Hirsch']
  spec.email         = ['gabriel.chaney@gmail.com', '5thWall@gmail.com', 'jonah.w.h@gmail.com']
  spec.summary       = 'A thin abstraction on-top-of sneakers to DRY your workers. Pump it up!'
  spec.description   = 'This gem allows you to DRY up your sneakers workers by using a conventions-based configuration. It also includes a LaGear::Bus class that allows you to pass in more options when publishing to an exchange.'
  spec.homepage      = 'https://github.com/giftcardzen/la_gear'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/).reject { |f| f == 'Gemfile.lock' }
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']
  spec.add_dependency 'json', '~> 1.8'
  spec.add_dependency 'bunny', '~> 2.2.0'
  spec.add_dependency 'sneakers', '~> 2.3'
  spec.add_dependency 'activesupport', '< 6.0', '>= 4.0'
  spec.add_dependency 'sidekiq', '>= 3.3'
  spec.add_dependency 'connection_pool', '~> 2.1'

  spec.add_development_dependency 'rake', '~> 10.4'
  spec.add_development_dependency 'minitest', '~> 5.7.0'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'mocha'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'codeclimate-test-reporter', '~> 0.6.0'
end
