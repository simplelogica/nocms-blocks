module NoCms
  module Blocks
    class LayoutGenerator < Rails::Generators::Base

      source_root File.expand_path("../templates/", __FILE__)

      argument :name, required: true, banner: '<layout name>', desc: 'Name for the block layout'

      def generate_stylesheets
        template "app/assets/stylesheets/no_cms/blocks/layout.scss.erb", File.join(destination_root, "app/assets/stylesheets/no_cms/blocks", "_#{name}.scss")
      end

      def generate_views
        template "app/views/no_cms/blocks/blocks/layout.html.erb", File.join(destination_root, "app/views/no_cms/blocks/blocks", "_#{name}.html.erb")
        template "app/views/no_cms/admin/blocks/blocks/layout.html.erb", File.join(destination_root, "app/views/no_cms/admin/blocks/blocks", "_#{name}.html.erb")
        template "app/views/no_cms/blocks/skeletons/default.html.erb", File.join(destination_root, "app/views/no_cms/blocks/skeletons", "_#{name}.html.erb")
      end

      def generate_initializer
        template "config/initializers/nocms/blocks/layout.rb", File.join(destination_root, "config/initializers/nocms/blocks", "#{name}.rb")
      end

      def self.namespace
        "nocms:blocks:layout"
      end

    end
  end
end
