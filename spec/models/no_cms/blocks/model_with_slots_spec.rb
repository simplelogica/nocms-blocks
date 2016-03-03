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

  # The child slot needs the container empty and will get the paren container with a before_validation
  it_behaves_like "model with has many relationship", :block_slot, :block_slot_without_contaier, :children, :parent

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

  context "when duplicating with nested slots" do
    let(:block) { create(:block, layout: 'default') }
    let(:slot) { create :block_slot, block: block, container: page }
    let!(:nested_slot) { create :block_slot, block: block, parent: slot }
    let(:page) { create :slotted_page }
    let(:dupped_page) { page.dup }

    subject { dupped_page }

    it {expect(subject.block_slots).to_not include slot }
    it {expect(subject.block_slots).to_not include nested_slot }

    context "and save" do
      before { dupped_page.save }

      it { is_expected.to be_valid }
      it { expect(subject.block_slots.count).to eq 2 }
      it {expect(subject.block_slots).to_not include slot }
      it {expect(subject.block_slots).to_not include nested_slot }
    end

  end


end
