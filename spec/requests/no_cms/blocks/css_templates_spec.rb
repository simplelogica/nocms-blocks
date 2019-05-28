require 'spec_helper'
include ActionView::Helpers::AssetUrlHelper

describe NoCms::Blocks::Block do

  context "when blocks have CSS templates" do

    before do
      NoCms::Blocks.configure do |config|
        config.block_layouts = {
          'general1' => {
            template: 'block_with_css_files',
            fields: {
              title: :string,
              body: :text
            },
            css_templates: css_templates
          }
        }
      end

      create(:block_slot, block: block_with_css_files, container: container, template_zone: 'header')

      visit Dummy::Application.routes.url_helpers.slotted_page_path(container)
    end

    let(:container) { create :slotted_page, template: 'default' }

    let(:block_with_css_files) { NoCms::Blocks::Block.create attributes_for(:block).merge(layout: 'general1') }

    let(:css_templates) do
      [
        'general1_desktop',
        'general1_mobile',
        'general1_tablet',
        'general1_all',
        'general1_global', # this should test if there's no valid mediaquery name we don't break
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
      css_templates.map{|css_template| "#{NoCms::Blocks.css_blocks_folder}/general1/#{css_template}" }.
        zip(css_mediaqueries)
    end

    subject { block_with_layout }

    it("should show the stylesheet tags") do

      expected_css_templates.each do |template, mediaquery|
        if mediaquery
          expect(page).to have_selector("link[rel=stylesheet][href='#{stylesheet_path(template)}'][media='#{mediaquery}']")
        else
          expect(page).to have_selector("link[rel=stylesheet][href='#{stylesheet_path(template)}']")
        end
      end
    end



  end

end
