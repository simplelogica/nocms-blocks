class NoCms::Blocks::BaseSerializer

  attr_accessor :container, :field

  def initialize field, container
    @field = field
    @container = container
  end

end
