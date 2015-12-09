$:.unshift(File.expand_path('../lib', __FILE__))
require File.dirname(__FILE__) + '/../../../../config/environment'

require 'rails/test_help'
require 'mocha'

ActionController::Base.logger = nil
ActionController::Routing::Routes.reload rescue nil
