module NoCms::Blocks

  ##
  # This class implements the read/write behaviour for fields affected by the
  # "multiple" setting. As an example, this may include ActiveRecord and ActiveResource
  # serializers.
  #
  # It relies on its subclasses implementing a multiple and single versions for
  # the read and write methods.
  class BaseMultipleSerializer < BaseSerializer


    ##
    # This method is the "read" implementation for the serializer.
    #
    # Depending on the field being configured as multiple or not it delegates
    # the reading to the `read_multiple_field` or `read_single_field`.
    def read_field
      if field_config[:multiple]
        read_multiple_field
      else
        read_single_field
      end
    end

    ##
    # Method to be implemented by the subclasses with the behaviour for reading
    # a field not configured as multiple.
    def read_single_field
      raise NotImplementedError.new("The serializer #{self.inspect} has no 'read_single_field' implementation")
    end

    ##
    # Method to be implemented by the subclasses with the behaviour for reading
    # a field configured as multiple.
    def read_multiple_field
      raise NotImplementedError.new("The serializer #{self.inspect} has no 'read_multiple_field' implementation")
    end

    ##
    # This method is the "write" implementation for the serializer.
    #
    # Depending on the field being configured as multiple or not it delegates
    # the writing to the `write_multiple_field` or `write_single_field`.
    def write_field value
      if field_config[:multiple]
        write_multiple_field value
      else
        write_single_field value
      end
    end

    ##
    # Method to be implemented by the subclasses with the behaviour for writing
    # a field not configured as multiple.
    def write_single_field value
      raise NotImplementedError.new("The serializer #{self.inspect} has no 'write_single_field' implementation")
    end

    ##
    # Method to be implemented by the subclasses with the behaviour for writing
    # a field configured as multiple.
    def write_multiple_field values
      raise NotImplementedError.new("The serializer #{self.inspect} has no 'write_multiple_field' implementation")
    end

    ##
    # In fields configured as multiple and with the :dup behaviour, we have to
    # get the whole array or relation and dup each element one by one. Otherwise
    # we just dup the array.
    #
    # In any other case (the field is not multiple or has any other duplication
    # behaviour) we are fine with the default behaviour from BaseSerializer.
    def duplicate
      if field_config[:multiple] && field_config[:duplicate] == :dup
        field_value = read
        dupped_value = case field_value
        when nil
          nil
        when Array, ActiveRecord::Relation
          field_value.map(&:dup)
        else
          field_value.dup
        end
        write dupped_value
      else
        super
      end
    end
  end
end
