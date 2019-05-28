require 'spec_helper'

describe NoCms::Blocks::Block do

  context "when blocks have layouts" do

    context "with simple fields" do

      before do
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

      let(:block_with_layout) { NoCms::Blocks::Block.create attributes_for(:block).merge(layout: 'title-long_text', title: block_title) }
      let(:block_title) { Faker::Lorem.sentence }

      subject { block_with_layout }

      it("should respond to layout fields") do
        expect{subject.title}.to_not raise_error
        expect{subject.body}.to_not raise_error
      end

      it("should not respond to fields from other layouts") do
        expect{subject.no_title}.to raise_error(NoMethodError)
      end

      it("should save info in layout fields") do
        expect(subject.title).to eq block_title
      end

      it("should save nil fields") do
        expect(subject.body).to be_blank
      end

      context "when updating various fields" do

        let(:new_block_title) { "new #{Faker::Lorem.sentence}" }
        let(:block_body) { Faker::Lorem.paragraph }

        before do
          subject.update_attributes title: new_block_title, body: block_body
        end

        it("should save info in layout fields") do
          expect(subject.title).to eq new_block_title
          expect(subject.body).to eq block_body
        end

      end

      context "when updating just one field" do

        let(:new_block_title) { "new #{Faker::Lorem.sentence}" }

        before do
          subject.update_attribute :title, new_block_title
        end

        it("should save info in layout field") do
          expect(subject.title).to eq new_block_title
        end

      end

    end
  end
end
