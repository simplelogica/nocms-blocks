module NoCms::Blocks
  class SimpleFieldSerializer < BaseSerializer

    def read
      self.container.fields_info[self.field]
    end

  end
end
