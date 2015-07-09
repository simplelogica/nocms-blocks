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

    ## If we have a fields config we fill the fields hash
    unless config[:fields].nil?
      config[:fields].each do | field, field_config|
        # If configuration is not a hash it means that we are only receiving
        # the field type. We turn it into a proper hash.
        field_config = { type: field_config } unless field_config.is_a? Hash
        @fields[field] = field_config
      end
    end

    @fields
  end

  def template
    config[:template]
  end

  def allow_nested_blocks
    config.has_key?(:allow_nested_blocks) ?
      config[:allow_nested_blocks] :
      false
  end
  alias_method :allow_nested_blocks?, :allow_nested_blocks

  def nest_levels
    config[:nest_levels] || []
  end

  def cache_enabled
    config.has_key?(:cache_enabled) ?
      config[:cache_enabled] :
      NoCms::Blocks.cache_enabled
  end
  alias_method :cache_enabled?, :cache_enabled

  ##
  # We look for the layout_id into the engine configuration and return a layout
  # initialized with the corresponding configuration data
  def self.find layout_id
    layout_config = NoCms::Blocks.block_layouts.stringify_keys[layout_id.to_s]
    NoCms::Blocks::Layout.new layout_config unless layout_config.nil?
  end

end
