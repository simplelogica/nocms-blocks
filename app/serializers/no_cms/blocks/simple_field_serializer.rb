module NoCms::Blocks
  class SimpleFieldSerializer < BaseSerializer

    def read
      self.container.fields_info[self.field]
    end

    def write value
      self.container.fields_info[self.field] = value
    end

  end
end
