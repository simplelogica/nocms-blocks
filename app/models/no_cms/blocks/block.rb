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
    # In the block we get all the fields so it can accept all of them
    def fields_configuration
      layout_config.fields
    end

    validates :layout, presence: true
    validates :fields_info, presence: { allow_blank: true }

    class Translation
      attr_accessor :layout

      ##
      # In the translation we get only the translated fields
      def fields_configuration
        layout_config.translated_fields
      end

      def layout
        globalized_model.nil? ? @layout : globalized_model.layout
      end

      include  NoCms::Blocks::Concerns::SerializingFields
    end

    accepts_nested_attributes_for :children, allow_destroy: true
    accepts_nested_attributes_for :translations

  end
end
