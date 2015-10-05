module NoCms::Blocks
  ##
  # This class implements the read/write behaviour for dates.
  #
  # It's just like the SimpleFieldSerializer but it parses and builds dates
  class DateSerializer < BaseSerializer

    ##
    # It parses the date from the value in the fields_info hash. It uses the
    # class in the field configuration to parse the saved string
    def read_field
      date_string = self.container.fields_info[self.field]
      date_string.blank? ? nil : self.field_config[:type].parse(date_string)
    end

    ##
    # It stores the value in the fields_info hash
    def write_field value
      self.container.fields_info[self.field] = value.strftime('%Y-%m-%dT%H:%M:%S.%N %Z')
    end

  end
end
