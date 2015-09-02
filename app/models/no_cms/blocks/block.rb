module NoCms::Blocks
  class Block < ActiveRecord::Base

    include  NoCms::Blocks::Concerns::TranslationScopes

    acts_as_nested_set

    has_many :slots, class_name: "NoCms::Blocks::BlockSlot"

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

    ##
    # A block dups all it's children and the translations
    def duplicate_self new_self

      new_self.translations = translations.map(&:dup)
      new_self.translations.each { |t| t.globalized_model = new_self }

      children.each do |child|
        new_self.children << child.dup
      end
    end

    class Translation

      ##
      # In the translation we get only the translated fields
      def fields_configuration
        layout_config.translated_fields
      end

      ##
      # Sometimes the translation still won't have the globalized_model linked
      # (e.g. before it's saved for the first time) and we must have a mechanism
      # to be able to store a temporary layout
      attr_accessor :layout

      ##
      # If we don't have a globalized model yet we return our temporary layout
      def layout
        globalized_model.nil? ? @layout : globalized_model.layout
      end

      include  NoCms::Blocks::Concerns::SerializingFields
    end

    accepts_nested_attributes_for :children, allow_destroy: true
    accepts_nested_attributes_for :translations

  end

end
