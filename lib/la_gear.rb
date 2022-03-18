require 'la_gear/version'

require 'json'
require 'active_support/inflector'
require 'bunny'

require 'sneakers'
require 'sidekiq'
require 'la_gear/sneakers'
require 'la_gear/worker'
require 'la_gear/publisher'
require 'la_gear/bus'
require 'la_gear/uri_parser'
require 'la_gear/sneakers_configurer'

module LaGear
  module Rails
    if defined? ::Rails::Engine
      require 'la_gear/engine'
    end
  end
end
