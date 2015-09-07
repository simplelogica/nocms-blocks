##
# This class will manage all the information about a bone, a zone of a skeleton
# where the blocks are allowed or not.
class NoCms::Blocks::Bone
  attr_reader :config
  attr_reader :name

  DEFAULT_FIELD_CONFIGURATION = { translated: true, duplicate: :dup }

  ##
  # We receive a name, a bone configuration hash like the ones defined in the configuration
  # files and the skeleton object associated
  def initialize name, config, skeleton
    @config = config
    @name = name
    @skeleton = skeleton
  end

  ##
  # This method returns a mix of the blocks allowed for this bone and the ones
  # allowed for the skeleton gobally
  def allowed_blocks
    return @allowed_blocks if @allowed_blocks
    @allowed_blocks = [config[:blocks], @skeleton.allowed_blocks].compact.flatten.uniq
    @allowed_blocks = NoCms::Blocks.block_layouts.keys if @allowed_blocks.blank?
    @allowed_blocks
  end

  def to_param
    name
  end

  def human_name
    I18n.t("no_cms.blocks.bones.#{self.name}")
  end

end
