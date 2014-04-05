module NoCms
  module Blocks
    include ActiveSupport::Configurable

    config_accessor :block_layouts

    self.block_layouts = {
      'default' => {
        template: 'default',
        fields: {
          title: :string,
          body: :text
        }
      }
    }

  end
end
