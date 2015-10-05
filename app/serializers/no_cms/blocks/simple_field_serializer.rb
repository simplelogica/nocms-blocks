module NoCms::Blocks
  ##
  # This class implements the default read/write behaviour for simple fields
  # (integers, strings...).
  #
  # It acts as a default serializer and just read and writes from the
  # fields_info from the container.
  class SimpleFieldSerializer < BaseSerializer

    ##
    # It reads the value from the fields_info hash
    def read_field
      self.container.fields_info[self.field]
    end

    ##
    # It stores the value in the fields_info hash
    def write_field value
      self.container.fields_info[self.field] = value
    end

  end
end
