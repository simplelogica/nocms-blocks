require 'spec_helper'

describe NoCms::Blocks::BlockSlot do

  context "when visiting a page with slots" do

    let(:image_attributes) { attributes_for(:test_image) }
    let(:block_default_layout) { create :block, layout: 'default', title: Faker::Lorem.sentence, body: Faker::Lorem.paragraph }
    let(:block_3_columns_layout) { create :block, layout: 'title-3_columns', title: Faker::Lorem.sentence, column_1: Faker::Lorem.paragraph, column_2: Faker::Lorem.paragraph, column_3: Faker::Lorem.paragraph }
    let(:block_logo) { create :block, layout: 'logo-caption', caption: Faker::Lorem.sentence, logo: image_attributes }
    let(:block_draft) { create :block, layout: 'default', title: Faker::Lorem.sentence, body: Faker::Lorem.paragraph, draft: true }
    let(:slotted_page) { create :slotted_page }
    let(:nestable_container_block) { create :block, layout: 'nestable_container', title: Faker::Lorem.sentence }
    let(:nestable_container_block_slot) { create :block_slot, block: nestable_container_block }
    let(:nested_block) { create :block, layout: 'default', title: nested_title, body: Faker::Lorem.paragraph }
    let(:nested_block_slot) { create :block_slot, block: nested_block, parent: nestable_container_block_slot }
    let(:nested_title) { "#{Faker::Lorem.sentence}-#{Time.now.to_i}" }

    before do
      NoCms::Blocks.configure do |config|
        config.block_layouts = {
          'default' => {
            template: 'default',
            fields: {
              title: :string,
              body: :text
            }
          },
          'title-3_columns' => {
            template: 'title_3_columns',
            fields: {
              title: :string,
              column_1: :text,
              column_2: :text,
              column_3: :text
            }
          },
          'logo-caption' => {
            template: 'logo_caption',
            fields: {
              caption: :string,
              logo: TestImage
            }
          },
          'nestable_container' => {
            template: 'nestable_container',
            fields: {
              title: :string,
            },
            allow_nested_blocks: true
          },

        }

      end

      slotted_page.blocks << block_default_layout
      slotted_page.blocks << block_3_columns_layout
      slotted_page.blocks << block_logo
      slotted_page.blocks << block_draft
      slotted_page.block_slots << nestable_container_block_slot
      slotted_page.block_slots << nested_block_slot

      visit Dummy::Application.routes.url_helpers.slotted_page_path(slotted_page)

    end

    it("should display default layout block") do
      expect(page).to have_selector('.title', text: block_default_layout.title)
      expect(page).to have_selector('.body', text: block_default_layout.body)
    end

    it("should display 3 columns layout block") do
      expect(page).to have_selector('h2', text: block_3_columns_layout.title)
      expect(page).to have_selector('.column_1', text: block_3_columns_layout.column_1)
      expect(page).to have_selector('.column_2', text: block_3_columns_layout.column_2)
      expect(page).to have_selector('.column_3', text: block_3_columns_layout.column_3)
    end

    it("should display logo layout block") do
      expect(page).to have_selector('.caption', text: block_logo.caption)
      expect(page).to have_selector("img[src='#{block_logo.logo.logo.url}']")
    end

    it("should display the nested block") do
      expect(page).to have_selector('.title', text: nested_title)
    end

    it("should display not draft block") do
      expect(page).to_not have_selector('.title', text: block_draft.title)
      expect(page).to_not have_selector('.body', text: block_draft.body)
    end

    context "when a cache key is rendered by a block", caching: true do

      let(:block_logo) { create :block, layout: 'logo-caption', caption: Faker::Lorem.sentence, logo: image_attributes }
      let(:cache_key) { 'supercalifragilisticoespialidoso' }
      let(:second_cache_key) { 'supercalifragilisticoes-pia-li-do-so' }

      before { block_logo }

      it("should not cache it") do
        visit Dummy::Application.routes.url_helpers.slotted_page_path(slotted_page)
        expect(page).to_not have_text cache_key
        visit Dummy::Application.routes.url_helpers.slotted_page_path(slotted_page, "cache_key" => cache_key)
        expect(page).to have_text cache_key
        visit Dummy::Application.routes.url_helpers.slotted_page_path(slotted_page, "cache_key" => second_cache_key)
        expect(page).to have_text second_cache_key
      end

    end

  end


end
