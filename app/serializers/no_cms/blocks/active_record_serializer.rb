module NoCms::Blocks

  class ActiveRecordSerializer < BaseSerializer

    def read
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

    def write value
      read.assign_attributes value
      container.fields_info_will_change!
    end
  end
end
