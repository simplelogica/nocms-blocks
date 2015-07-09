##
# This class will manage all the information about block layouts (e.g: How is
# it retrieved from configuration files? Which is the default configuration for
# any field?).
class NoCms::Blocks::Layout

  attr_reader :config

  ##
  # We receive a configuration hash like the ones defined in the configuration
  # files
  def initialize config
    @config = config
  end

  ##
  # We look for the layout_id into the engine configuration and return a layout
  # initialized with the corresponding configuration data
  def self.find layout_id
    layout_config = NoCms::Blocks.block_layouts.stringify_keys[layout_id.to_s]
    NoCms::Blocks::Layout.new layout_config unless layout_config.nil?
  end

end
