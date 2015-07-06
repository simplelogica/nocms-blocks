module NoCms::Blocks
  class Block < ActiveRecord::Base

    include  NoCms::Blocks::Concerns::TranslationScopes

    acts_as_nested_set

    scope :drafts, ->() { where_with_locale(draft: true) }
    scope :no_drafts, ->() { where_with_locale(draft: false) }
    scope :roots, ->() { where parent_id: nil }

    accepts_nested_attributes_for :children, allow_destroy: true

    translates :layout, :fields_info, :draft
    accepts_nested_attributes_for :translations

    class Translation
      serialize :fields_info, Hash
    end

    include  NoCms::Blocks::Concerns::SerializingFields

  end
end
