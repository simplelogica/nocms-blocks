module NoCms::Blocks

  ##
  # This class implements the read/write behaviour for ActiveRecord fields.
  #
  # It uses the objects cache from the container in order to store the objectand
  # update the _id field.
  class ActiveRecordSerializer < BaseSerializer


    ##
    # This method is the "read" implementation for the ActiveRecord serializer.
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
    # If the field is not present in our objects cache we fetch it from the
    # database using the id stored in the #{field}_id field.
    #
    # If we don't have the #{field}_id field then it builds (with new, not with
    # create) a new one and stores it in the objects cache. Later, if the block
    # is saved, this object will be saved too.
    def read_single_field
      # We get and return the object from the cached objects
      value = self.container.cached_objects[self.field.to_sym]
      return value if value

      # If there was nothing in the cache then we try to get the object id and
      # find the object in the database
      field_id = self.container.fields_info["#{field}_id".to_sym]
      value = field_config[:type].find(field_id) unless field_id.nil?

      # If we still don't have any object then we build a new one
      value = field_config[:type].new if value.nil?

      self.container.cached_objects[field.to_sym] = value
    end

    ##
    # If we don't have the array of objects in the cache object
    def read_multiple_field

      # We get and return the objects from the cached objects
      values = self.container.cached_objects[self.field.to_sym]
      return values if values

      # If there was nothing in the cache then we try to get the object ids
      field_ids = self.container.fields_info["#{field}_ids".to_sym]

      # If there's any id we try to get them from the database
      if field_ids.blank?
        []
      else
        values = field_config[:type].where(id: field_ids)
        self.container.cached_objects[field.to_sym] = values
      end

    end

    ##
    # This method is the "write" implementation for the ActiveRecord serializer.
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
    # This method expects `value` to be a Hash or an ActiveRecord object.
    #
    # When `value` is a Hash we load the object and assign the hash through an
    # assign_attributes. This solves the scenario of a nested form where a hash
    # is passed as the value of the field.
    #
    # When `value` is an object (or nil) we save it in the object's cache and
    # overwrite the _id field
    def write_single_field value
      case value
      when Hash
        read_single_field.assign_attributes value
      when ActiveRecord::Base, nil
        # We save in the objects cache the new value
        self.container.cached_objects[field.to_sym] = value
        # and then we store the new id in the fields_info hash
        self.container.fields_info["#{field}_id".to_sym] = value.nil? ? nil : value.id
      end

      value
    end

    #
    # This method `value` to be a Hash or an ActiveRecord object.
    #
    # When `value` is a Hash we load the object and assign the hash through an
    # assign_attributes. This solves the scenario of a nested form where a hash
    # is passed as the value of the field.
    #
    # When `value` is an object (or nil) we save it in the object's cache and
    # overwrite the _id field
    def write_multiple_field values
      raise ArgumentError.new "Array expected for #{field} attribute" unless values.is_a? Array

      self.container.cached_objects[field.to_sym] = values.map do |value|
        case value
        when Hash
          if value.has_key? :id
            object = field_config[:type].find(value[:id])
            object.assign_attributes value
            object
          else
            field_config[:type].new value
          end
        when ActiveRecord::Base, nil
          value
        else
          raise ArgumentError.new "Hash, ActiveRecord or nil expected for #{field} attribute"
        end
      end

      self.container.fields_info["#{field}_ids".to_sym] = self.container.cached_objects[field.to_sym].map(&:id)

    end
  end
end
