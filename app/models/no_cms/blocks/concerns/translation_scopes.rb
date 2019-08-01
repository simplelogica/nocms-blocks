module NoCms
  module Blocks
    module Concerns
      module TranslationScopes
        extend ActiveSupport::Concern

        included do
          scope :where_with_locale, ->(where_params, locale = ::I18n.locale) {
            # In Rails 5.2 "self" doesn't return the model itself but an
            # ActiveRecord::Relation model that has no Translation. We have to
            # use the `model` attribute
            translation_model = if Rails.version >= "5.2.0"
                self.model::Translation
              else
                self::Translation
              end

            with_translations(locale).where(translation_model.table_name => where_params)
          }
        end

      end
    end
  end
end
