module NoCms::Blocks

  ##
  # This class implements the read/write behaviour for ActiveRecord fields.
  #
  # It uses the objects cache from the container in order to store the objectand
  # update the _id field.
  class ActiveRecordSerializer < BaseMultipleSerializer

    def id_field
      field_config[:multiple] ? "#{field}_ids".to_sym : "#{field}_id".to_sym
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
      field_id = self.container.fields_info.symbolize_keys[id_field]

      # Hstore serializes every field as a string, so we have to turn it into an
      # integer
      field_id = field_id.to_i if field_id && NoCms::Blocks.database_serializer == :hstore

      value = field_config[:type].find(field_id) unless field_id.nil?

      # If we still don't have any object then we build a new one
      value = field_config[:type].new if value.nil?

      self.container.cached_objects[field.to_sym] = value
    end

    ##
    # If we don't have the array of objects in the cache object we fetch it from the
    # database using the id stored in the #{field}_ids field.
    #
    # If we don't have the #{field}_ids field or it's blank then it returns an
    # empty array.
    def read_multiple_field

      # We get and return the objects from the cached objects
      values = self.container.cached_objects[self.field.to_sym]
      return values if values

      # If there was nothing in the cache then we try to get the object ids
      field_ids = self.container.fields_info.symbolize_keys[id_field]

      # Hstore serializes every field as a string, so we have to turn "[1, 2]"
      # to an actual array of integers
      if NoCms::Blocks.database_serializer == :hstore
        field_ids = field_ids.gsub(/[\[\]]/, '').split(',').map(&:to_i)
      end

      # If there's any id we try to get them from the database
      if field_ids.blank?
        field_config[:type].none
      else
        values = field_config[:type].where(id: field_ids)
        self.container.cached_objects[field.to_sym] = values
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
        self.container.fields_info[id_field] = value.nil? ? nil : value.id
      else
        raise ArgumentError.new "Hash, ActiveRecord or nil expected for #{field} attribute"
      end

      value
    end

    #
    # This method expects `value` to be an array of Hashes or ActiveRecord
    # objects.
    #
    # When a hash comes with an id attribute then we get the object from the
    # database and assign it the attributes. In other case we create a new
    # record.
    #
    # When an object (or nil) is in the array we just get it.
    #
    # Then we get all the objects in the objects cache and save the ids in the
    # ids field.
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

      self.container.fields_info[id_field] = self.container.cached_objects[field.to_sym].map(&:id)

    end
  end
end
