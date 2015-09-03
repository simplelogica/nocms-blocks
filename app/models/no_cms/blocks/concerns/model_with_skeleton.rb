module NoCms::Blocks::Concerns
  module ModelWithSkeleton
    extend ActiveSupport::Concern

    self.included do |klass|

      def self.allowed_skeletons
        NoCms::Blocks.skeletons.keys
      end

      validates :skeleton, presence: true,
        inclusion: { in: klass.allowed_skeletons.map(&:to_s) }

      def skeleton_config
        @skeleton_config ||= NoCms::Blocks::Skeleton.find(self.skeleton)
      end

    end

  end
end
