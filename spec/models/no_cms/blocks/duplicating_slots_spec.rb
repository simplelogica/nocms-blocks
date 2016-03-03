require 'spec_helper'

describe NoCms::Blocks::BlockSlot do

  before(:all) do
    NoCms::Blocks.configure do |config|
      config.block_layouts = {
        'body' => {
          template: 'body',
          fields: {
            title: :string,
            body: :text
          }
        }
      }
    end
  end

  let(:block_title) { Faker::Lorem.sentence }
  let(:block_body) { Faker::Lorem.paragraph }
  let(:block) { create :block, layout: 'body', title: block_title, body: block_body }
  let(:slot) { create :block_slot, template_zone: 'body', block: block }

  context "when duplicating a slot and its block" do

    let(:dupped_slot) do
      slot.dup_block_when_duping_slot = true
      slot.dup
    end

    subject { dupped_slot }

    it "should have the a block with the same info" do
      expect(subject.block.layout).to eq slot.block.layout
      expect(subject.block.title).to eq slot.block.title
      expect(subject.block.body).to eq slot.block.body
    end

    it "should not have the same block" do
      expect(subject.block).to_not eq slot.block
    end

    context "and have nested slot" do
      let(:nested_block) { create :block, layout: 'body' }
      let!(:nested_slot) { create(:block_slot, block: nested_block, parent: slot, template_zone: 'body', dup_block_when_duping_slot: true) }

      subject { dupped_slot.children.first }

      it "should have different slot" do
        expect(subject).to_not eq nested_slot
      end

      it "should have the dupped parent" do
        expect(subject.parent).to eq dupped_slot
      end

      it "should have the same info" do
        expect(subject.template_zone).to eq nested_slot.template_zone
      end

      it "should not have the same block" do
        expect(subject.block).to_not eq nested_slot.block
      end

    end

  end

  context "when duplicating a slot but not its block" do

    let(:dupped_slot) { slot.dup }

    subject { dupped_slot }

    it "should have the same block" do
      expect(subject.block).to eq slot.block
    end

    context "and have nested slot" do
      let(:nested_block) { create :block, layout: 'body' }
      let!(:nested_slot) { create(:block_slot, block: nested_block, parent: slot, template_zone: 'body') }

      subject { dupped_slot.children.first }

      it "should have different slot" do
        expect(subject).to_not eq nested_slot
      end

      it "should have the dupped parent" do
        expect(subject.parent).to eq dupped_slot
      end

      it "should have the same info" do
        expect(subject.template_zone).to eq nested_slot.template_zone
      end

      it "should have the same block" do
        expect(subject.block).to eq nested_slot.block
      end
    end

  end
end
