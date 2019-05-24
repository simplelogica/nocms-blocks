require 'spec_helper'

describe NoCms::Blocks::Block do

  context "when blocks have CSS templates" do

    before do
      NoCms::Blocks.configure do |config|
        config.block_layouts = {
          'title-long_text' => {
            template: 'title-long_text',
            fields: {
              title: :string,
              body: :text
            },
            css_templates: css_templates
          }
        }
      end
    end

    let(:block_with_layout) { NoCms::Blocks::Block.create attributes_for(:block).merge(layout: 'title-long_text') }
    let(:css_templates) do
      [
        'title-long_text_desktop',
        'title-long_text_mobile',
        'title-long_text_tablet',
        'title-long_text_all',
        'title-long_text_global', # this should test if there's no valid mediaquery name we don't break
        'title-global' # this should test if there's no mediaquery name we don't break
      ]
    end

    let(:css_mediaqueries) do
      [
        NoCms::Blocks.css_mediaqueries[:desktop],
        NoCms::Blocks.css_mediaqueries[:mobile],
        NoCms::Blocks.css_mediaqueries[:tablet],
        NoCms::Blocks.css_mediaqueries[:all],
        nil,
        nil
      ]
    end

    let(:expected_css_templates) do
      css_templates.map{|css_template| "#{NoCms::Blocks.css_blocks_folder}/title-long_text/#{css_template}" }.
        zip(css_mediaqueries)
    end

    subject { block_with_layout }

    it("should return its css files and media queries") do
      expect(subject.css_files).to eq expected_css_templates
    end



  end

end
