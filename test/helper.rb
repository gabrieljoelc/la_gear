ENV['RACK_ENV'] = ENV['RAILS_ENV'] = 'test'
require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start

begin
  require 'pry-byebug'
rescue LoadError
end
require 'minitest/autorun'
require 'minitest/pride'
require 'mocha/mini_test'
require 'sidekiq'
require 'sneakers'

require 'la_gear'

require 'active_support/all'
require 'pry'

ActiveSupport::TestCase.test_order = :random

LaGear::Test = Minitest::Test
LaGear::Spec = Minitest::Spec
