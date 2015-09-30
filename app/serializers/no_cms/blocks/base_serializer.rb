class NoCms::Blocks::BaseSerializer

  attr_accessor :container, :field, :field_config

  def initialize field, field_config, container
    @field = field
    @field_config = field_config
    @container = container
  end

  def read
    raise NotImplementedError.new("The serializer has no 'read' implementation")
  end

  def write value
    raise NotImplementedError.new("The serializer has no 'write' implementation")
  end

  def duplicate

    field_value = read

    dupped_value = case field_config[:duplicate]
      # When dupping we just dup the object and expect it has the right
      # behaviour. If it's nil we save nil (you can't dup NilClass)
      when :dup
        field_value.nil? ? nil : field_value.dup
      # When nullifying we return nil
      when :nullify
        nil
      when :link
        field_value
    end

    write dupped_value

  end

end
