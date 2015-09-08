module NoCms::Blocks::Concerns
  module ModelWithTemplate
    extend ActiveSupport::Concern

    self.included do |klass|

      def self.allowed_templates
        NoCms::Blocks.templates.keys
      end

      validates :template, presence: true,
        inclusion: { in: klass.allowed_templates.map(&:to_s) }

      def template_config
        @template_config ||= NoCms::Blocks::Template.find(self.template)
      end

      def template_zones
        template_config.zones
      end

    end

  end
end
