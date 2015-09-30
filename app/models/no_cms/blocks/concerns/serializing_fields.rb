module NoCms
  module Blocks
    module Concerns
      module SerializingFields
        extend ActiveSupport::Concern

        self.included do

          serialize :fields_info, Hash

          after_initialize :set_blank_fields

          before_save :save_related_objects

          validates :fields_info, presence: { allow_blank: true }

          ##
          # This attribute stores all the objects referenced on those fields
          # from an AR subtype.
          #
          # It acts both as a cache and as a way to edit or create AR objects
          # and save them when the block is saved.
          attr_reader :cached_objects


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
            !layout_config.field(field).nil? # We have this field
          end

          ##
          # This method tells wether we are in a translation and we must manage
          # translated fields or not
          def is_translation?
            !self.respond_to?(:translations)
          end

          ##
          # Returns the type of a field in the current layout configuration of
          # this block.
          #
          # If the field is not present in the layout configuration it returns
          # nil.
          #
          # If the field is the id of an ActiveRecord field then we return
          # :id
          def field_type field
            return nil unless has_field?(field)

            # If the field exists in the fields configuration then we return its
            # type
            if fields_configuration.symbolize_keys[field.to_sym]
              fields_configuration.symbolize_keys[field.to_sym][:type]
            # If it doesn't (but remember! the has_field? method returned true)
            # then it must be an ActiveRecord field's id.
            else
              :id
            end
          end

          def field_serializer field
            @field_serializers ||= {}
            @field_serializers[field] if @field_serializers.has_key? field

            field_class = field_type(field)

            if field_class.is_a? Class
              _, serializer = NoCms::Blocks.serializers.detect do |serialized_class, _|
                field_class < serialized_class.constantize
              end
            end

            serializer ||= NoCms::Blocks.default_serializer
            @field_serializers[field] = serializer.constantize.new field, self
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
            raise  NoMethodError.new("field #{field} is not defined in the block layout") unless has_field?(field)

            return field_serializer(field.to_sym).read

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
            raise NoMethodError.new("field #{field} is not defined in the block layout") unless has_field?(field)
            field_type = field_type field
            # If field type is a model then we update the cached object
            if field_type.is_a?(Class) && field_type < ActiveRecord::Base

              # We read the object and assign it the attributes attributes.
              # Since we use the read_field method it will take into account
              # if the AR object needs to be build
              read_field(field).assign_attributes value

              # Even if the fields_info has not changed we need to store the
              # modification, so an association may be saved in cascade (e.g.
              # the translation of a block would not be saved if we don't force
              # this)
              fields_info_will_change!
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
          # This method duplicates a field and stores its value.
          #
          # It takes into account that the field may be an AR object and updates
          # the cached objects.
          #
          # We have different options of duplication depending on the field's
          # configuration:
          #
          #  * duplication: It's the default behaviour. It just performs a dup
          #    of the field and expects the attached object to implement dup in
          #    a proper way.
          #
          #  * nullify: It doesn't dup the field, it empties it. It's useful for
          #    objects we don't want to duplicate, like images in S3 (it can
          #    raise a timeout exception when duplicating).
          #
          #  * link: It doesn't dup the field but stores the same object. It's
          #    useful in Active Record fields so we can store the same id and
          #    not creating a duplicate of the object (e.g. if we have a block
          #    with a related post we don't want the post to be duplicated)
          def duplicate_field field
            field_type = field_type field
            field_value = read_field(field)

            dupped_value = case layout_config.field(field)[:duplicate]
              # When dupping we just dp the object and expect it has the right
              # behaviour. If it's nil we save nil (you can't dup NilClass)
              when :dup
                field_value.nil? ? nil : field_value.dup
              # When nullifying we return nil
              when :nullify
                nil
              when :link
                field_value
            end

            if field_type.is_a?(Class) && field_type < ActiveRecord::Base
              # We save in the objects cache the dupped object
              @cached_objects[field.to_sym] = dupped_value
              # and then we store the new id in the fields_info hash
              fields_info["#{field}_id".to_sym] =
                dupped_value.nil? ? nil : dupped_value.id
            else
              # else we just dup it and save it into fields_info.
              fields_info[field.to_sym] = dupped_value
            end
          end

          ##
          # Saves every related object from the objects cache
          def save_related_objects
            # Now we save each activerecord related object
            @cached_objects.each do |field, object|
              # Notice that we don't care if the object is actually saved.
              #
              # We don't care because there may be some cases where no real
              # information is sent to an object but something is sent (i.e. the
              # locale in a new Globalize translation) and then the object is
              # created empty.
              #
              # When this happens if we save! the object an error is thrown and
              # we can't leave the object blank
              if object.is_a?(ActiveRecord::Base) && object.save
                fields_info["#{field}_id".to_sym] = object.id
              end
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


            # If we don't have this field then we send it to super and pry
            if field == 'layout' || !has_field?(field)
              super
            # If this field exists, and it's not translated, then we do whatever
            # we need to do
            elsif !layout_config.field(field)[:translated]
              write_accessor ?
                write_field(field, args.first) :
                read_field(field.to_sym)

              # If it's translated but we are not in the translation (we check
              # this by checking if we have translations) then we use the
              # default translation to obtain it
            elsif !self.is_translation? &&
                layout_config.field(field)[:translated]

                # When we are creating the block we still have no translation
                # and we need to fill the layout. Otherwise no write or read
                # field will work
                translation.layout = self.layout

                  write_accessor ?
                    translation.write_field(field, args.first) :
                    translation.read_field(field.to_sym)
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
            # Now we filter those fields we must not manage because we are (or
            # not) in a translation. I.e: if we have a translated field, but we
            # are not in a translation then we let the translated field go and
            # not manage it here
            fields.select!{|k, _| layout_config.field(k)[:translated] == is_translation? }

            # We purge the fields from the attributes
            new_attributes.reject!{|k, _| fields.has_key? k }

            # If we have translations we're going to need the layout in their
            # attributes too so they can validate the fields.
            # This is actually only neccesary when creating the translations,
            # but we can afford to send the layout always to the translations
            if new_attributes.has_key? :translations_attributes
              new_attributes[:translations_attributes].each do |translation|
                translation[:layout] = self.layout
              end
            end

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

          ##
          # Overwriting duplication method. This method relies on super for any
          # default behaviour, then duplicate the fields just as their
          # configuration demands and then allow the object to custimize the
          # duplication through the duplicate_self method.
          def dup
            new_self = super

            # Now we recover all the fields that must be duplicated here
            fields_to_duplicate.keys.each do |field_to_duplicate|
              new_self.duplicate_field field_to_duplicate
            end

            # And allow the class itself to append some behaviour
            duplicate_self new_self

            new_self
          end

          ##
          # This method allows us to introduce some custom duplication for each
          # class that includes the concern.
          #
          # Basic behaviour is... doing nothing
          def duplicate_self new_self
          end

          ##
          # This method returns a list of the fields to duplicate in this
          # object. In the concern we will use all the fields and if the classes
          # need to modify it they will.
          #
          # Notice that if the behaviour is that when duplicating the field is
          # nullfied we will return the field here and the duplicate_field will
          # manage it properly.
          def fields_to_duplicate
            fields_configuration
          end

          ##
          # When dupping we need to overwrite the cached_objects attribute.
          # Otherwise the cached_object from the original object would start to
          # be populated with the objects of the dupped one.
          def initialize_dup(other)
            @cached_objects = {}
            super
          end

          private

          ##
          # Initializes both the fields_info hash and the objects cache.
          def set_blank_fields
            @fields_info ||= {}
            @cached_objects ||= {}
          end

        end
      end
    end
  end
end
