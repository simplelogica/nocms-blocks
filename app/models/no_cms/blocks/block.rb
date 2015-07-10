module NoCms::Blocks
  class Block < ActiveRecord::Base

    include  NoCms::Blocks::Concerns::TranslationScopes

    acts_as_nested_set

    scope :drafts, ->() { where_with_locale(draft: true) }
    scope :no_drafts, ->() { where_with_locale(draft: false) }
    scope :roots, ->() { where parent_id: nil }

    translates :draft
    include  NoCms::Blocks::Concerns::SerializingFields

    ##
    # This attribute stores all the objects referenced on those fields
    # from an AR subtype.
    #
    # It acts both as a cache and as a way to edit or create AR objects
    # and save them when the block is saved.
    attr_reader :cached_objects

    validates :layout, presence: true
    validates :fields_info, presence: { allow_blank: true }

    class Translation
      attr_accessor :layout

      def layout
        globalized_model.nil? ? @layout : globalized_model.layout
      end

      include  NoCms::Blocks::Concerns::SerializingFields
    end

    accepts_nested_attributes_for :children, allow_destroy: true
    accepts_nested_attributes_for :translations

    before_save :save_related_objects

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

  end
end
