##
# This class will manage all the information about a bone, a zone of a skeleton
# where the blocks are allowed or not.
class NoCms::Blocks::Bone
  attr_reader :config
  attr_reader :name

  DEFAULT_FIELD_CONFIGURATION = { translated: true, duplicate: :dup }

  ##
  # We receive a configuration hash like the ones defined in the configuration
  # files
  def initialize name, config
    @config = config
    @name = name
  end

end
