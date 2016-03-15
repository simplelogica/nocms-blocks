require 'spec_helper'

describe NoCms::Blocks::Block do

  context "when visiting the home" do

    let(:block_custom_layout) { create :block, layout: 'wadus', title: Faker::Lorem.sentence, body: Faker::Lorem.paragraph }
    let(:block_unset_default_layout) { create :block, layout: 'default', title: Faker::Lorem.sentence, body: Faker::Lorem.paragraph }
    let(:block_undefined_layout) { create :block, layout: 'undefined', title: Faker::Lorem.sentence, body: Faker::Lorem.paragraph }

    before do
      NoCms::Blocks.configure do |config|
        config.block_layouts = {
          'wadus' => {
            template: 'default',
            template_layout: 'wadus',
            fields: {
              title: :string,
              body: :text
            }
          },
          'undefined' => {
            template: 'default',
            template_layout: 'undefined',
            fields: {
              title: :string,
              body: :text
            }
          },
          'default' => {
            template: 'default',
            fields: {
              title: :string,
              body: :text
            }
          }
        }

      end

      block_custom_layout
      block_unset_default_layout
      block_undefined_layout

      visit '/'

    end

    it("should use template layout when it's specified in config") do
      expect(page).to have_selector(".wadus-#{block_custom_layout.id}", text: "wadus-#{block_custom_layout.id}")
    end

    it("should not break and use default partial layout when is not specified") do
      expect(page).to have_selector(".block-custom-layout-#{block_unset_default_layout.id}", text: "default-#{block_unset_default_layout.id}")
    end

    it("should not break and use default partial layout when a undefined partial is set") do
      expect(page).to have_selector(".block-custom-layout-#{block_undefined_layout.id}", text: "default-#{block_undefined_layout.id}")
    end


  end


end
