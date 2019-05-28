module NoCms
  class BlocksGenerator < Rails::Generators::Base

    source_root File.expand_path("../templates/", __FILE__)

    def generate_nocms_pages_initializer
      template "config/initializers/nocms/blocks.rb", File.join(destination_root, "config", "initializers", "nocms", "blocks.rb")
    end

    def self.namespace
      "nocms:blocks"
    end

  end
end
