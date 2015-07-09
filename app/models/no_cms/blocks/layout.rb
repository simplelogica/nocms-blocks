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
  # This method parses the fields block from the layout configuration and takes
  # into account if they are declared in a verbose mode (with a hash) or a quick
  # one (just the field type).
  #
  # It uses default values for the configuration that is not declared
  def fields
    return @fields if @fields

    @fields = {}

    config[:fields].each do | field, field_config|

      field_config = { type: field_config } unless field_config.is_a? Hash

      @fields[field] = field_config

    end

    @fields
  end

  def template
    config[:template]
  end

  def allow_nested_blocks
    config[:allow_nested_blocks]
  end

  def nest_levels
    config[:nest_levels]
  end

  def cache_enabled
    config[:cache_enabled]
  end

  ##
  # We look for the layout_id into the engine configuration and return a layout
  # initialized with the corresponding configuration data
  def self.find layout_id
    layout_config = NoCms::Blocks.block_layouts.stringify_keys[layout_id.to_s]
    NoCms::Blocks::Layout.new layout_config unless layout_config.nil?
  end

end
