##
# This class will manage all the information about the template, the collection
# of zones and allowed blocks to manage restrictions about where every block is
# allowed to be.
class NoCms::Blocks::Template

  attr_reader :config, :name

  DEFAULT_TEMPLATE_CONFIGURATION = { blocks: [ ], lazy_blocks: [ ] }

  ##
  # We receive a configuration hash like the ones defined in the configuration
  # files
  def initialize name, config
    @config = DEFAULT_TEMPLATE_CONFIGURATION.merge config
    @name = name
  end

  ##
  # This method returns the blocks allowed globally for this template. If no
  # block is allowed then we return an empty array
  def allowed_layouts
    return @allowed_layouts if @allowed_layouts
    @allowed_layouts = [config[:blocks], config[:lazy_blocks]].compact.flatten.uniq
  end

  ##
  # This method returns an array of the zones contained by this template with
  # its configuration
  def zones
    @zones ||= config[:zones].map do |zone_name, zone_config|
      NoCms::Blocks::Zone.new zone_name, zone_config, self
    end
  end

  ##
  # This method returns the configuration for just one zone which name is passed
  # as parameter
  def zone zone_id
    zones.detect{|b| b.name.to_s == zone_id.to_s }
  end

  ##
  # We look for the template_id into the engine configuration and return a
  # template initialized with the corresponding configuration data
  def self.find template_id
    template_config = NoCms::Blocks.templates.stringify_keys[template_id.to_s]
    NoCms::Blocks::Template.new template_id, template_config unless template_config.nil?
  end

  ##
  # Two templates are the same if they have the same template name
  def == another
    self.name == another.name
  end

  def human_name
    I18n.t("no_cms.blocks.templates.#{self.name}")
  end

  ##
  # This method returns wether the template is appliable to the model parameter
  # according to the configuration
  def appliable? model
    config[:models].blank? || config[:models].include?(model.name)
  end

end
