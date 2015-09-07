##
# This class will manage all the information about skeletons, the collection of
# zones (bones) and allowed blocks to manage restrictions about where every
# block is allowed to be.
class NoCms::Blocks::Skeleton

  attr_reader :config, :name

  DEFAULT_FIELD_CONFIGURATION = { translated: true, duplicate: :dup }

  ##
  # We receive a configuration hash like the ones defined in the configuration
  # files
  def initialize name, config
    @config = config
  end

  ##
  # This method returns the blocks allowed globally for this skeleton. If no
  # block is allowed then we return an empty array
  def allowed_blocks
    return @allowed_blocks if @allowed_blocks
    @allowed_blocks = config[:blocks] || []
  end

  ##
  # This method returns an array of the bones contained by this skeleton with
  # its configuration
  def bones
    @bones ||= config[:bones].map do |bone_name, bone_config|
      NoCms::Blocks::Bone.new bone_name, bone_config, self
    end
  end

  ##
  # This method returns the configuration for just one bone which name is passed
  # as parameter
  def bone bone_id
    bones.detect{|b| b.name.to_s == bone_id.to_s }
  end

  ##
  # We look for the skeleton_id into the engine configuration and return a
  # skeleton initialized with the corresponding configuration data
  def self.find skeleton_id
    skeleton_config = NoCms::Blocks.skeletons.stringify_keys[skeleton_id.to_s]
    NoCms::Blocks::Skeleton.new skeleton_id, skeleton_config unless skeleton_config.nil?
  end

  ##
  # Two skeletons are the same if they have the same skeleton name
  def == another
    self.name == another.name
  end

end
