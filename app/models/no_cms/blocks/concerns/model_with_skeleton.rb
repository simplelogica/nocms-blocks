module NoCms::Blocks::Concerns
  module ModelWithSkeleton
    extend ActiveSupport::Concern

    self.included do

      validates :skeleton, presence: true,
        inclusion: { in: NoCms::Blocks.skeletons.keys.map(&:to_s) }

      def skeleton_config
        @skeleton_config ||= NoCms::Blocks::Skeleton.find(self.skeleton)
      end

      def allowed_block_layouts

      end
    end

  end
end
