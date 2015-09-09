require 'spec_helper'

describe NoCms::Blocks::BlockSlot do

  context "when the slot is built with a block with a wrong layout" do

    let(:container) { build(:slotted_page, template: 'default' ) }
    let(:block) { build(:block, layout: 'header1') }
    let(:slot) { build :block_slot, container: container , template_zone: 'body', block: block }

    it "detects that the layout is not valid" do
      expect(slot).to_not be_valid
    end

    it "detects that the layout is not valid" do
      block.slots << slot
      expect(block).to_not be_valid
    end

    it "detects that the layout is not valid" do
      container.block_slots << slot
      expect(container).to_not be_valid
    end

  end

end
