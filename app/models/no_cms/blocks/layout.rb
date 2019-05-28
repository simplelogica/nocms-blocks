##
# This class will manage all the information about block layouts (e.g: How is
# it retrieved from configuration files? Which is the default configuration for
# any field?).
class NoCms::Blocks::Layout

  attr_reader :config

  DEFAULT_FIELD_CONFIGURATION = { translated: {
      fallback_on_blank: NoCms::Blocks.i18n_fallback_on_blank
    },
    duplicate: :dup,
    multiple: false
  }

  DEFAULT_BLOCK_CONFIGURATION = {
    skeleton_template: 'default',
    css_templates: ''
  }

  ##
  # We receive a configuration hash like the ones defined in the configuration
  # files
  def initialize config
    @config = DEFAULT_BLOCK_CONFIGURATION.merge config
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
        # If configuration is not a hash it means that we are only receiving the
        # field type. We turn it into a proper hash and then merge it with the
        # default configuration
        field_config = { type: field_config } unless field_config.is_a? Hash
        @fields[field] = DEFAULT_FIELD_CONFIGURATION.merge field_config
      end
    end

    @fields = @fields.symbolize_keys

    @fields
  end

  def field field_name
    field_name = field_name.to_sym
    if fields.has_key? field_name
      fields[field_name]
    elsif field_name.to_s.ends_with? "_id"
      field_name = field_name.to_s.gsub(/\_id$/, '').to_sym
      fields[field_name] if fields.has_key? field_name
    elsif field_name.to_s.ends_with? "_ids"
      field_name = field_name.to_s.gsub(/\_ids$/, '').pluralize.to_sym
      fields[field_name] if fields.has_key? field_name
    end
  end

  ##
  # This method returns only the configuration for translated fields
  def translated_fields
    @translated_fields ||= fields.select{|field, config| config[:translated] }
  end


  ##
  # This method returns only the configuration for not translated fields
  def not_translated_fields
    @not_translated_fields ||= fields.reject{|field, config| config[:translated] }
  end

  def template
    config[:template]
  end

  def skeleton_template
    config[:skeleton_template]
  end

  def css_templates
    config[:css_templates]
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
