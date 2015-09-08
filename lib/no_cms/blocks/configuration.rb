module NoCms
  module Blocks
    include ActiveSupport::Configurable

    config_accessor :block_layouts
    config_accessor :cache_enabled
    config_accessor :templates


    self.templates = {
      'default' => {
        blocks: nil,
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

  end
end
