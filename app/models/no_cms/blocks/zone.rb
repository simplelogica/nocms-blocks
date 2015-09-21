##
# This class will manage all the information about a zone of a template where
# the blocks are allowed or not.
class NoCms::Blocks::Zone
  attr_reader :config
  attr_reader :name

  DEFAULT_FIELD_CONFIGURATION = { translated: true, duplicate: :dup }

  ##
  # We receive a name, a zone configuration hash like the ones defined in the configuration
  # files and the template object associated
  def initialize name, config, template
    @config = config
    @name = name
    @template = template
  end

  ##
  # This method returns a mix of the blocks allowed for this zone and the ones
  # allowed for the template gobally
  def allowed_layouts
    return @allowed_layouts if @allowed_layouts
    @allowed_layouts = [config[:blocks], @template.allowed_layouts].compact.flatten.uniq
    @allowed_layouts = NoCms::Blocks.block_layouts.keys if @allowed_layouts.blank?
    @allowed_layouts
  end

  def to_param
    name
  end

  def human_name
    I18n.t("no_cms.blocks.template_zones.#{self.name}")
  end

end
