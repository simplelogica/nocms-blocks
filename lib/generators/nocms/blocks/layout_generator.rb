module NoCms
  module Blocks
    class BlockGenerator < Rails::Generators::Base

      source_root File.expand_path("../templates/", __FILE__)

      argument :name, required: true, banner: '<layout name>', desc: 'Name for the block layout'

      def self.namespace
        "nocms:blocks:layout"
      end

    end
  end
end
