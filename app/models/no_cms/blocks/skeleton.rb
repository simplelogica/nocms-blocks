##
# This class will manage all the information about skeletons, the collection of
# zones (bones) and allowed blocks to manage restrictions about where every
# block is allowed to be.
class NoCms::Blocks::Skeleton

  attr_reader :config

  DEFAULT_FIELD_CONFIGURATION = { translated: true, duplicate: :dup }

  ##
  # We receive a configuration hash like the ones defined in the configuration
  # files
  def initialize config
    @config = config
  end

  ##
  # This method returns an array of the bones contained by this skeleton with
  # its configuration
  def bones
    @bones ||= config[:bones].map do |bone_name, bone_config|
      bone_config = bone_config.merge({blocks: config[:blocks]}) do |original_value, new_value|
        [original_value, new_value].compact.flatten.uniq
      end
      NoCms::Blocks::Bone.new bone_name, bone_config
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
    NoCms::Blocks::Skeleton.new skeleton_config unless skeleton_config.nil?
  end

end
