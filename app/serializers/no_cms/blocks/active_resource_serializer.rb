module NoCms::Blocks

  ##
  # This class implements the read/write behaviour for ActiveResource fields.
  #
  # It uses the objects cache from the container in order to store the object
  # and updates the _id field.
  #
  class ActiveResourceSerializer < BaseMultipleSerializer

    ##
    # If the field is not present in our objects cache we fetch it from the
    # API using the id stored in the #{field}_id field.
    #
    # If we don't have the #{field}_id field then it builds (with build, not with
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
      value = field_config[:type].build if value.nil?

      self.container.cached_objects[field.to_sym] = value
    end

    ##
    # If we don't have the array of objects in the cache object we fetch it from the
    # API using the id stored in the #{field}_ids field.
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

      # If there's any id we try to get them from the API
      if field_ids.blank?
        []
      else
        values = field_config[:type].find_all(field_ids)
        self.container.cached_objects[field.to_sym] = values
      end
    end

    ##
    # This method `value` to be a Hash or an ActiveResource object.
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
        resource = read
        value.each do |attribute_name, attribute_value|
          resource.send("#{attribute_name}=", attribute_value)
        end
      when ActiveResource::Base, nil
        # We save in the objects cache the new value
        self.container.cached_objects[field.to_sym] = value
        # and then we store the new id in the fields_info hash
        self.container.fields_info[id_field] = value.nil? ? nil : value.id
      end

      value
    end

    #
    # This method expects `value` to be an array of Hashes or ActiveResource
    # objects.
    #
    # When a hash comes with an id attribute then we get the object from the
    # API and assign it the attributes. In other case we create a new
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
            field_config[:type].new  value
          end
        when ActiveResource::Base, nil
          value
        else
          raise ArgumentError.new "Hash, ActiveRecord or nil expected for #{field} attribute"
        end
      end

      self.container.fields_info[id_field] = self.container.cached_objects[field.to_sym].map(&:id)

    end

    ##
    # We need to override the link behaviour this method for active resource in
    # order to not find and save AR fields in blocks. When the field type is an
    # ActiveRecord, it doesn't matter, but with ActiveResource we have multiple
    # errors in duplication time
    #
    # And we also control the behaviour when the field value is empty in the
    # original block. We just leave it empty in this block. Otherwise we fall to
    # the default behaviour.
    #
    # This is due to the bug that caused the creation of new objects from nil
    # records in the original block.
    def duplicate

      # We look for the _id or _ids field and also check wether we have the
      # object in the cached obects (in case one has been initialized in the
      # original block but not yet saved)
      if self.container.fields_info[id_field] ||
        self.container.cached_objects[field.to_sym]


        if field_config[:duplicate] == :link
          dupped_value = if field_config[:multiple]

              # when linking we use the exact same objects if we already have
              # them in the cached objects
              if self.container.cached_objects[field.to_sym]
                self.container.cached_objects[field.to_sym]
              else
                # Id we don't have them we save API calls by just creating
                # persisted active resource objects with the right id
                field_ids = self.container.fields_info.symbolize_keys[id_field]
                field_ids.map{|id| field_config[:type].new({ id: id }, true )}
              end
            else
              self.container.fields_info[id_field]
            end

          write dupped_value

        else
          super
        end
      end
    end
  end
end
