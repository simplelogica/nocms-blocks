require 'spec_helper'

describe NoCms::Blocks::BlockSlot do

    before(:all) do
      NoCms::Blocks.configure do |config|
        config.block_layouts = {
          'title-long_text' => {
            template: 'title-long_text',
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

    let(:slot) { create :block_slot, block: create(:block,
      layout: 'title-long_text',
      title: block_title,
      body: block_body)
    }

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

  end

  context "when duplicating a slot but not its block" do

    let(:dupped_slot) { slot.dup }

    subject { dupped_slot }

    it "should have the same block" do
      expect(subject.block).to eq slot.block
    end

  end

end
