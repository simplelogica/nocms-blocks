module NoCms::Blocks

  ##
  # This class implements the read/write behaviour for ActiveResource fields.
  #
  # It uses the objects cache from the container in order to store the object
  # and updates the _id field.
  class ActiveResourceSerializer < BaseSerializer

    ##
    # If the field is not present in our objects cache we fetch it from the
    # API using the id stored in the #{field}_id field.
    #
    # If we don't have the #{field}_id field then it builds (with build, not with
    # create) a new one and stores it in the objects cache. Later, if the block
    # is saved, this object will be saved too.
    def read_field
      # We get and return the object from the cached objects
      value = self.container.cached_objects[self.field.to_sym]
      return value if value

      # If there was nothing in the cache then we try to get the object id and
      # find the object in the database
      field_id = self.container.fields_info["#{field}_id".to_sym]
      value = field_config[:type].find(field_id) unless field_id.nil?

      # If we still don't have any object then we build a new one
      value = field_config[:type].build if value.nil?

      self.container.cached_objects[field.to_sym] = value
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
    def write_field value
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
        self.container.fields_info["#{field}_id".to_sym] = value.nil? ? nil : value.id
      end

      value
    end
  end
end
