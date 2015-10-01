require 'spec_helper'

describe NoCms::Blocks::Block do

  context "when blocks are marked as draft" do

    let(:no_draft_blocks) { create_list :block, 2, draft: false }
    let(:draft_blocks) { create_list :block, 2, draft: true }

    before { draft_blocks && no_draft_blocks }

    it("should distinguish between drafts and no drafts") do
      expect(NoCms::Blocks::Block.drafts).to match_array draft_blocks
      expect(NoCms::Blocks::Block.no_drafts).to match_array no_draft_blocks
    end
  end
end
