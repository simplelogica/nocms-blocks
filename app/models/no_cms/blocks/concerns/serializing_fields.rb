module NoCms
  module Blocks
    module Concerns
      module SerializingFields
        extend ActiveSupport::Concern

        self.included do

          serialize :fields_info, NoCms::Blocks.database_serializer

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

          ##
          # This method returns the field Serializer attached to the `field`
          # passed as parameter.
          #
          # To avoid calculating the same several times we cache the results in
          # a field_serializers variable, so the serializer is only calculated
          # the first time.
          def field_serializer field
            # We try if the serializer is already cachd
            @field_serializers ||= {}
            @field_serializers[field] if @field_serializers.has_key? field

            # If it's not we obtain the field type
            field_class = field_type(field)

            # If the field is an object then we check which serializer is the
            # right one. We iterate through the configured serializers and get
            # the first one attached to a parent class of the field (e.g if we
            # have an ActiveRecordModel it will get the serializer configured
            # for ActiveRecord::Base)
            if field_class.is_a? Class
              _, serializer = NoCms::Blocks.serializers.detect do |serialized_class, _|
                field_class <= serialized_class.constantize
              end
            end

            # if we have no serializer, then we get the default one
            serializer ||= NoCms::Blocks.default_serializer

            # And cache it and return it
            @field_serializers[field] = serializer.constantize.new field, layout_config.field(field), self
          end

          ##
          # This method uses the field serializer to read a field
          def read_field field
            raise  NoMethodError.new("field #{field} is not defined in the block layout") unless has_field?(field)
            field_serializer(field.to_sym).read
          end

          ##
          # This method uses the field serializer to write a field and store
          # its value.
          def write_field field, value
            raise NoMethodError.new("field #{field} is not defined in the block layout") unless has_field?(field)
            field_serializer(field.to_sym).write value
          end

          ##
          # This method uses the field serializer to duplicate a field and store
          # its value.
          def duplicate_field field
            return field_serializer(field).duplicate
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
              if object.is_a? Array
                saveable_objects = object.select{|o| o.respond_to?(:save)}
                saveable_objects.each(&:save)
                fields_info["#{field}_ids".to_sym] = saveable_objects.map(&:id)
              elsif object.respond_to?(:save) && object.save
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
            begin
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
            rescue StandardError => e
              Rails.logger.error "Error while accessing #{m}"
              Rails.logger.error e.message
              Rails.logger.error e.backtrace.join("\n")
              raise e
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
              " in #{self.layout} layout #{is_translation? ? 'translation' : ''}"

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

            Rails.logger.info "Assigning #{new_attributes.inspect} through Rails"

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
            fields_configuration.select{|k, config| config[:translated] == is_translation? }
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
            # When we are serializing to JSON we need to create also the field,
            # as it's not a Hash by default.
            # We also need to make sure that the
            # object has the fields_info attribute. This is due to Globalize,
            # since the object can be a strange Block::translation without any
            # field created
            self.fields_info ||= {} if (NoCms::Blocks.database_serializer == JSON) &&
              self.respond_to?(:fields_info)

            @cached_objects ||= {}
          end

        end
      end
    end
  end
end
