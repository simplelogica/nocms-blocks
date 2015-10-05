require 'spec_helper'

describe NoCms::Blocks::Block do

  context "when blocks have layouts" do

    context "with a date field" do

      before do
        NoCms::Blocks.configure do |config|
          config.block_layouts = {
            'title-long_text' => {
              template: 'title-long_text',
              fields: {
                starts_at: DateTime,
                ends_at: DateTime
              }
            }
          }
        end
      end

      let(:block_with_layout) { NoCms::Blocks::Block.create attributes_for(:block).merge(layout: 'title-long_text', starts_at: starts_at_example) }
      let(:starts_at_example) {  1.day.from_now }

      subject { block_with_layout }

      it("should respond to layout fields") do
        expect{subject.starts_at}.to_not raise_error
      end

      it("should save info in layout fields") do
        expect(subject.starts_at).to eq starts_at_example
      end

      it("should save nil fields") do
        expect(subject.ends_at).to be_blank
      end

      it("should return dates") do
        expect(subject.starts_at).to be_a DateTime
      end


    end
  end
end
