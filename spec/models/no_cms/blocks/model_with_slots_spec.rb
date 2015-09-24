require 'spec_helper'

describe NoCms::Blocks::Concerns::ModelWithSlots do

  before do
    NoCms::Blocks.configure do |config|
      config.block_layouts = {
        'default' => {
          template: 'default',
          fields: {
            title: :string,
            body: :text
          }
        }
      }

    end
  end

  it_behaves_like "model with has many relationship", :slotted_page, :block_slot, :block_slots, :container

  it_behaves_like "model with has many through belongs to relationship",
    :slotted_page, :block_slot, :block, :block_slots, :block, :blocks

  it_behaves_like "model with has many relationship", :block_slot, :block_slot, :children, :parent

  context "when duplicating the model but not its block" do

    let!(:page) { create :slotted_page, block_slots: create_list(:block_slot, 2, block: create(:block, layout: 'default')) }
    let(:dupped_page) { page.dup }

    subject { dupped_page }

    it "should have the same blocks" do
      expect(subject.block_slots).to_not be_blank
      expect(subject.block_slots.first.block).to eq page.block_slots.first.block
    end

  end

  context "when duplicating the model and its block" do

    let!(:page) { create :slotted_page, block_slots: create_list(:block_slot, 2, block: create(:block, layout: 'default')), dup_block_when_duping_slots: true }
    let(:dupped_page) { page.dup }

    subject { dupped_page }

    it "should not have the same block" do
      expect(subject.block_slots).to_not be_blank
      expect(subject.block_slots.first.block).to_not eq page.block_slots.first.block
    end

  end


end
