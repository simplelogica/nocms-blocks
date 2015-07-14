require 'spec_helper'

describe NoCms::Blocks::Block do

  context "when duplicating a block without translations" do

    let(:block_title) { Faker::Lorem.sentence }
    let(:image_attributes) {  }
    let(:block) do
      NoCms::Blocks::Block.create layout: 'title-long_text',
        title: block_title,
        body: Faker::Lorem.paragraph,
        logo: attributes_for(:test_image),
        background: attributes_for(:test_image)
    end


    let(:dupped_block) { block.dup }


    before(:all) do
      NoCms::Blocks.configure do |config|
        config.block_layouts = {
          'title-long_text' => {
            template: 'title-long_text',
            fields: {
              title: { type: :string, translated: false },
              body: { type: :text, translated: false, duplicate: :nullify },
              logo: { type: TestImage, translated: false, duplicate: :dup },
              background: { type: TestImage, translated: false, duplicate: :nil }
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

    it "should nullify the field configured to be nullified" do
      expect(subject.body).to be_nil
    end

    it "should duplicate an Active Record field configured to be duplicated" do
      expect(subject.logo).to_not be_new_record
      expect(subject.logo).to_not eq block.logo
    end

    it "should return a new record when an AR field is configured to nullify" do
      expect(subject.background).to be_new_record
    end

  end

end
