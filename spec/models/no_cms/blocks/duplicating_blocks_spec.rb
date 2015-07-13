require 'spec_helper'

describe NoCms::Blocks::Block do

  context "when duplicating a block without translations" do
    let(:block_title) { Faker::Lorem.sentence }
    let(:block) { NoCms::Blocks::Block.create layout: 'title-long_text', title: block_title }

    let(:dupped_block) { block.dup }


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

    before { dupped_block.save! }

    subject { NoCms::Blocks::Block.find dupped_block.id }

    it "should have the same layout" do
      expect(subject.layout).to eq block.layout
    end

    it "should have the same text" do
      expect(subject.title).to eq block_title
    end
  end

end
