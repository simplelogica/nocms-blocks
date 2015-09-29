require 'spec_helper'

describe NoCms::Blocks::Block do

  context "when loading simple translated fields" do
    let(:block_title_es) { Faker::Lorem.sentence }
    let(:block_title_en) { Faker::Lorem.sentence }
    let!(:block) { NoCms::Blocks::Block.create! layout: 'title-long_text',
      translations_attributes: [
        { locale: 'es', title: block_title_es },
        { locale: 'en', title: block_title_en }
      ]
    }

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

    subject { NoCms::Blocks::Block.find block.id }

    it "should have retrieve the right text for each language" do
      I18n.with_locale(:es) { expect(subject.title).to eq block_title_es }
      I18n.with_locale(:en) { expect(subject.title).to eq block_title_en }
    end

    context "from globalize_fields_for hash" do

      let!(:block) { NoCms::Blocks::Block.create! layout: 'title-long_text',
        translations_attributes: {
          "1" => { "id" => "", "locale" => "es", "title" => block_title_es },
          "2" => { "id" => "", "locale" => "en", "title" => block_title_en }
        }
      }

      it "should have retrieve the right text for each language" do
        I18n.with_locale(:es) { expect(subject.title).to eq block_title_es }
        I18n.with_locale(:en) { expect(subject.title).to eq block_title_en }
      end

    end

  end

  context "when we have some untranslated fields" do
    let(:block_title) { Faker::Lorem.sentence }
    let(:block_body_es) { Faker::Lorem.paragraph }
    let(:block_body_en) { Faker::Lorem.paragraph }

    let(:logo_attributes) { attributes_for(:test_image) }
    let(:background_attributes_es) { attributes_for(:test_image) }
    let(:background_attributes_en) { attributes_for(:test_image) }

    let!(:block) { NoCms::Blocks::Block.create! title: block_title,
      logo: logo_attributes,
      layout: 'title-long_text',
      translations_attributes: [
        { locale: 'es', body: block_body_es, background: background_attributes_es },
        { locale: 'en', body: block_body_en, background: background_attributes_en }
      ]
    }

    before(:all) do
      NoCms::Blocks.configure do |config|
        config.block_layouts = {
          'title-long_text' => {
            template: 'title-long_text',
            fields: {
              title: { type: :string, translated: false },
              body: :text,
              logo:  { type: TestImage, translated: false },
              background:  { type: TestImage, translated: true },
            }
          }
        }
      end
    end

    subject { NoCms::Blocks::Block.find block.id }

    it "should retrieve the same unstranslated attribute for each language" do
      I18n.with_locale(:es) { expect(subject.title).to eq block_title }
      I18n.with_locale(:en) { expect(subject.title).to eq block_title }
    end

    it "should retrieve the right translated attribute for each language" do
      I18n.with_locale(:es) { expect(subject.body).to eq block_body_es }
      I18n.with_locale(:en) { expect(subject.body).to eq block_body_en }
    end

    it "should only create 3 images (2 translated and 1 not translated)" do
      expect(TestImage.count).to eq 3
    end

    it "should retrieve untranslated attached object" do
      logo_es = I18n.with_locale(:es) { subject.logo }
      logo_en = I18n.with_locale(:en) { subject.logo }
      expect(logo_es).to eq logo_en
    end

    it "should retrieve untranslated attached object" do
      background_es = I18n.with_locale(:es) { subject.background }
      background_en = I18n.with_locale(:en) { subject.background }
      expect(background_es).to_not eq background_en
    end

  end
end
