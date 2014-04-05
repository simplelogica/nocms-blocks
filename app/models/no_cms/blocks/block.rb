module NoCms::Blocks
  class Block < ActiveRecord::Base

    include Concerns::TranslationScopes

    acts_as_nested_set

    scope :drafts, ->() { where_with_locale(draft: true) }
    scope :no_drafts, ->() { where_with_locale(draft: false) }
    scope :roots, ->() { where parent_id: nil }

    accepts_nested_attributes_for :children, allow_destroy: true

    attr_reader :cached_objects

    translates :layout, :fields_info, :draft

    class Translation
      serialize :fields_info, Hash
    end

    after_initialize :set_blank_fields
    before_save :save_related_objects

    validates :fields_info, presence: { allow_blank: true }
    validates :layout, presence: true

    def layout_config
      NoCms::Blocks.block_layouts.stringify_keys[layout]
    end

    def template
      layout_config[:template] if layout_config
    end

    def has_field? field
      # We have the field if...
      !layout_config.nil? && # We have a layout configuration AND
        (
          !layout_config[:fields].symbolize_keys[field.to_sym].nil? || # We have this field OR
          !layout_config[:fields].symbolize_keys[field.to_s.gsub(/\_id$/, '').to_sym].nil? # we remove the final _id and then we have the field
        )
    end

    def field_type field
      return nil unless has_field?(field)
      layout_config[:fields].symbolize_keys[field.to_sym]
    end

    def read_field field
      return nil unless has_field?(field)

      value = fields_info[field.to_sym] || # first, we get the value
                @cached_objects[field.to_sym] # or we get it from the cached objects

      # If value is still nil, but the field exists we must get the object from the database
      if value.nil?
        field_type = field_type(field)
        field_id = fields_info["#{field}_id".to_sym]
        value = @cached_objects[field.to_sym] = field_type.find(field_id) unless field_id.nil?
      end

      # If value is still nil, and the field_type is an ActiveRecord class, then we
      if value.nil? && field_type.is_a?(Class)
        value = @cached_objects[field.to_sym] = field_type.new
      end
      value
    end

    def write_field field, value
      return nil unless has_field?(field)
      field_type = field_type field
      # If field type is a model then we update the cached object
      if field_type.is_a?(Class) && field_type < ActiveRecord::Base
        # First, we initialize the object if we don't read the object (it loads it into the cached objects)
        @cached_objects[field.to_sym] = field_type.new if read_field(field).nil?
        # Then, assign attributes
        @cached_objects[field.to_sym].assign_attributes value
      else # If it's a model then  a new object or update the previous one
        self.fields_info = fields_info.merge field.to_sym => value # when updating through an object (i.e. the page updates through nested attributes) fields_info[field.to_sym] = value doesn't work. Kudos to Rubo for this fix
      end
    end

    # In this missing method we check wether we're asking for one field
    # in which case we will read or write ir
    def method_missing(m, *args, &block)
      # We get the name of the field stripping out the '=' for writers
      field = m.to_s
      write_accessor = field.ends_with? '='
      field.gsub!(/\=$/, '')

      # If this field actually exists, then we write it or read it.
      if has_field?(field)
        write_accessor ?
          write_field(field, args.first) :
          read_field(field.to_sym)
      else
        super
      end
    end

    # When we are assigning attributes (this method is called in new, create...)
    # we must split those fields from our current layout and those who are not
    # (they must be attributes).
    # Attributes are processed the usual way and fields are written later
    def assign_attributes new_attributes
      fields = []

      set_blank_fields

      # We get the layout
      new_layout = new_attributes[:layout] || new_attributes['layout']
      self.layout = new_layout unless new_layout.nil?

      Rails.logger.info "Searching #{new_attributes.keys.inspect} fields in #{self.layout} layout"

      # And now separate fields and attributes
      fields = new_attributes.select{|k, _| has_field? k }.symbolize_keys
      new_attributes.reject!{|k, _| has_field? k }

      super(new_attributes)

      Rails.logger.info "Writing #{fields.inspect} to #{self.layout} block"

      fields.each do |field_name, value|
        self.write_field field_name, value
      end
    end

    def reload
      @cached_objects = {}
      super
    end

    private

    def set_blank_fields
      self.fields_info ||= {}
      @cached_objects ||= {}
    end

    def save_related_objects
      # Now we save each activerecord related object
      cached_objects.each do |field, object|
        # Notice that we don't care if the object is actually saved
        # We don't care because there may be some cases where no real information is sent to an object but something is sent (i.e. the locale in a new Globalize translation) and then the object is created empty
        # When this happens if we save! the object an error is thrown and we can't leave the object blank
        if object.is_a?(ActiveRecord::Base) && object.save
          fields_info["#{field}_id".to_sym] = object.id
        end
      end
    end
  end
end
