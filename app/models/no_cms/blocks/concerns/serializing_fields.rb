module NoCms
  module Blocks
    module Concerns
      module SerializingFields
        extend ActiveSupport::Concern

        self.included do
          after_initialize :set_blank_fields

          ##
          # This method checks wether the block's layout has cache configured
          # and returns it.
          #
          # If it hasn't it returns the global cache_enabled configuration for
          # NoCms::Blocks
          def cache_enabled?
            layout_config.cache_enabled?
          end

          ##
          # Old version without '?' mantained for historical reasons
          alias_method :cache_enabled, :cache_enabled?

          ##
          # Returns a hash with the layout information read from the blocks
          # initializer and the 'layout' field on the corresponding object.
          def layout_config
            return if layout.nil?
            @layout_config ||= NoCms::Blocks::Layout.find layout
          end

          ##
          # Returns the template read from the layout configuration
          def template
            layout_config.template if layout_config
          end

          ##
          # This method checks that we have the field passed as parameter in our
          # layout configuration.
          #
          # It also takes into account the case where we have an AR object and
          # we're asking just for its id.
          def has_field? field
            # We have the field if...
            !layout_config.nil? && # We have a layout configuration AND
              (
                # We have this field OR
                !layout_config.fields.symbolize_keys[field.to_sym].nil? ||
                # we remove the final _id and then we have the field
                !layout_config.fields.symbolize_keys[field.to_s.
                  gsub(/\_id$/, '').to_sym].nil?
              )
          end

          ##
          # Returns the type of a field in the current layout configuration of
          # this block.
          #
          # If the field is not present in the layout configuration it returns
          # nil.
          def field_type field
            return nil unless has_field?(field)
            layout_config.fields.symbolize_keys[field.to_sym][:type]
          end

          ##
          # Returns the stored value of the field for this block.
          #
          # If the field is not present in the layout configuration it returns
          # nil.
          #
          # If the field is an Active Record object but it's not present on our
          # objects cache we fetch it from the database using the id stored in
          # the #{field}_id field.
          #
          # If it's an Active Record object but we don't have the #{field}_id
          # field then it creates (with new, not with create) a new one and
          # stores it in the objects cache. Later, if the block is saved, this
          # object will be saved too.
          def read_field field
            return nil unless has_field?(field)

            # first, we get the value
            value = fields_info[field.to_sym] ||
                      # or we get it from the cached objects
                      @cached_objects[field.to_sym]

            # If value is still nil, but the field exists we must get the object
            # from the database
            if value.nil?
              field_type = field_type(field)
              field_id = fields_info["#{field}_id".to_sym]
              unless field_id.nil?
                value = field_type.find(field_id)
                @cached_objects[field.to_sym] = value
              end
            end

            # If value is still nil, and the field_type is an ActiveRecord
            # class, then we build a new one
            if value.nil? && field_type.is_a?(Class)
              value = field_type.new
              @cached_objects[field.to_sym] = value
            end
            value
          end

          ##
          # This method stores the parameter value into the corresponding field.
          #
          # If the field is an Active Record object then we load it into the
          # objects cache and assign it the value through an assign_attributes.
          # This solves the scenario of a nested form where a hash is passed as
          # the value of the field.
          def write_field field, value
            return nil unless has_field?(field)
            field_type = field_type field
            # If field type is a model then we update the cached object
            if field_type.is_a?(Class) && field_type < ActiveRecord::Base

              # We read the object and assign it the attributes attributes.
              # Since we use the read_field method it will take into account
              # if the AR object needs to be build
              read_field(field).assign_attributes value
            else
            # If it's not a model then we merge with the previous value

              # when updating through an object (i.e. the page updates through
              # nested attributes) fields_info[field.to_sym] = value doesn't
              # work. Kudos to Rubo for this fix
              self.fields_info = fields_info.nil? ?
                { field.to_sym => value } :
                fields_info.merge(field.to_sym => value)

            end
          end

          ##
          # In this missing method we check wether we're asking for one field
          # in which case we will read or write it.
          #
          # If there's no field we just let it go to super.
          def method_missing(m, *args, &block)
            # We get the name of the field stripping out the '=' for writers
            field = m.to_s
            write_accessor = field.ends_with? '='
            field.gsub!(/\=$/, '')

            # If this field actually exists, then we write it or read it.
            # Be careful, layout is not a serialized field, so the block has no
            # 'layout' field
            if field != 'layout' && has_field?(field)
              write_accessor ?
                write_field(field, args.first) :
                read_field(field.to_sym)
            else
              super
            end
          end

          ##
          # When we are assigning attributes (this method is called in new,
          # create...) we must split those fields from our current layout and
          # those who are not (they must be attributes).
          #
          # Attributes are processed the usual way and fields are written later
          def assign_attributes new_attributes
            fields = []

            set_blank_fields

            # We get the layout
            new_layout = new_attributes[:layout] || new_attributes['layout']
            self.layout = new_layout unless new_layout.nil?

            Rails.logger.info "Searching #{new_attributes.keys.inspect} fields"+
              "in #{self.layout} layout"

            # And now separate fields and attributes
            fields = new_attributes.select{|k, _| has_field? k }.symbolize_keys
            new_attributes.reject!{|k, _| has_field? k }

            super(new_attributes)

            Rails.logger.info "Writing #{fields.inspect} to #{self.layout} block"

            fields.each do |field_name, value|
              self.write_field field_name, value
            end
          end

          ##
          # It cleans the objects cache and executes the default behaviour.
          def reload *args
            @cached_objects = {}
            super
          end

          private

          ##
          # Initializes both the fields_info hash and the objects cache.
          def set_blank_fields
            self.fields_info ||= {}
            @cached_objects ||= {}
          end

        end
      end
    end
  end
end
