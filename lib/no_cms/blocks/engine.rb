module NoCms
  module Blocks
    class Engine < ::Rails::Engine
      isolate_namespace NoCms::Blocks
    end
  end
end
