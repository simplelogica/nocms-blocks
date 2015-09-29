require 'globalize'
require 'awesome_nested_set'
require 'active_resource'

module NoCms
  module Blocks
    class Engine < ::Rails::Engine
      isolate_namespace NoCms::Blocks

      config.to_prepare do
        Dir.glob(NoCms::Blocks::Engine.root + "app/decorators/**/*_decorator*.rb").each do |c|
          require_dependency(c)
        end
      end

    end
  end
end
