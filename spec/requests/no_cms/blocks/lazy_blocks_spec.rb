require 'spec_helper'

describe NoCms::Blocks::BlockSlot do

  context "when visiting a page with lazy blocks" do

    let(:not_lazy_block_in_zone) { create :block, layout: 'header1', title: "lazy-not-block-zone should be printed" }
    let(:lazy_block_in_zone) { create :block, layout: 'header2', title: "lazy-block-zone should not be printed" }
    let(:not_lazy_block_in_general) { create :block, layout: 'general1', title: "lazy-not-block-general should be printed" }
    let(:lazy_block_in_general) { create :block, layout: 'general2', title: "lazy-block-general should not be printed" }
    let(:mixed_block_not_in_lazy_zone) { create :block, layout: 'mixed_lazy_block', title: "mixed-block-not-lazy-zone should be printed" }
    let(:mixed_block_in_lazy_zone) { create :block, layout: 'mixed_lazy_block', title: "mixed-block-lazy-zone should not be printed" }
    let(:container) { create :slotted_page, template: 'default' }

    before do
      NoCms::Blocks.configure do |config|
        config.block_layouts = {
          'header1' => {
            template: 'default',
            fields: {
              title: :string
            }
          },
          'header2' => {
            template: 'default',
            fields: {
              title: :string
            }
          },
          'general1' => {
            template: 'default',
            fields: {
              title: :string
            }
          },
          'general2' => {
            template: 'default',
            skeleton_template: 'general2',
            fields: {
              title: :string
            }
          },
          'mixed_lazy_block' => {
            template: 'default',
            fields: {
              title: :string
            }
          }
        }
      end

      # Create blocks and slots after configuration
      create(:block_slot, block: lazy_block_in_zone, container: container, template_zone: 'header')
      create(:block_slot, block: not_lazy_block_in_zone, container: container, template_zone: 'header')
      create(:block_slot, block: lazy_block_in_general, container: container, template_zone: 'header')
      create(:block_slot, block: not_lazy_block_in_general, container: container, template_zone: 'header')
      create(:block_slot, block: mixed_block_in_lazy_zone, container: container, template_zone: 'header')
      create(:block_slot, block: mixed_block_not_in_lazy_zone, container: container, template_zone: 'body')

      visit Dummy::Application.routes.url_helpers.slotted_page_path(container)

    end

    it("should not display lazy blocks") do
      expect(page).to_not have_selector('.title', text: lazy_block_in_zone.title)
      expect(page).to have_selector(".skeleton.#{lazy_block_in_zone.layout}")
      expect(page).to_not have_selector('.title', text: lazy_block_in_general.title)
      expect(page).to have_selector(".skeleton-#{lazy_block_in_general.layout}")
      expect(page).to_not have_selector('.title', text: mixed_block_in_lazy_zone.title)
      expect(page).to have_selector(".skeleton.#{mixed_block_in_lazy_zone.layout}")

    end

    it("should display not lazy blocks") do
      expect(page).to have_selector('.title', text: not_lazy_block_in_zone.title)
      expect(page).to have_selector('.title', text: not_lazy_block_in_general.title)
      expect(page).to have_selector('.title', text: mixed_block_not_in_lazy_zone.title)
    end

  end


end
