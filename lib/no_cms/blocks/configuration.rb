module NoCms
  module Blocks
    include ActiveSupport::Configurable

    config_accessor :block_layouts
    config_accessor :cache_enabled
    config_accessor :templates


    self.templates = {
      'default' => {
        blocks: nil,
        models: [],
        zones: {
          header: {
            blocks: nil
          },
          body: {
            blocks: nil
          },
          footer: {
            blocks: nil
          }
        }
      }
    }

    self.block_layouts = {
      'default' => {
        template: 'default',
        fields: {
          title: :string,
          body: :text
        }
      }
    }
    self.cache_enabled = false

    def self.templates_config
      @templates_config ||= NoCms::Blocks.templates.map do |template_name, template_config|
        NoCms::Blocks::Template.new template_name, template_config
      end
    end

  end
end
