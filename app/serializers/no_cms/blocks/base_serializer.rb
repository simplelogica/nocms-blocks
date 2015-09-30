class NoCms::Blocks::BaseSerializer

  attr_accessor :container, :field, :field_config

  def initialize field, field_config, container
    @field = field
    @field_config = field_config
    @container = container
  end

end
