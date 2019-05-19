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
  # allowed for the template gobally.
  # We can also filter the layouts for a certain level
  def allowed_layouts nest_level = nil

    @allowed_layouts = [config[:blocks], config[:lazy_blocks], @template.allowed_layouts].compact.flatten.uniq
    @allowed_layouts = NoCms::Blocks.block_layouts.keys if @allowed_layouts.blank?
    @allowed_layouts = @allowed_layouts.select do |layout_name|
      layout = NoCms::Blocks.block_layouts[layout_name]
      layout[:nest_levels].blank? || layout[:nest_levels].include?(nest_level)
    end unless nest_level.nil?

    @allowed_layouts
  end

  ##
  # This method checks that the layout sent as param is configured as a lazy block in this template
  def is_lazy_layout? layout
    config[:lazy_blocks].map(&:to_s).include? layout
  end

  def to_param
    name
  end

  def human_name
    I18n.t("no_cms.blocks.template_zones.#{self.name}")
  end

end
