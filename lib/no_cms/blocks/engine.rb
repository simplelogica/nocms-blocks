require 'globalize'
require 'awesome_nested_set'

module NoCms
  module Blocks
    class Engine < ::Rails::Engine
      isolate_namespace NoCms::Blocks
    end
  end
end
