require 'spec_helper'

describe NoCms::Blocks::Block do

  context "when loading simple translated fields" do
    let(:block_title_es) { Faker::Lorem.sentence }
    let(:block_title_en) { Faker::Lorem.sentence }
    let!(:block) { NoCms::Blocks::Block.create! translations_attributes: [
        { locale: 'es', layout: 'title-long_text', title: block_title_es },
        { locale: 'en', layout: 'title-long_text', title: block_title_en }
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

  end

  context "when we have some untranslated fields" do
    let(:block_title) { Faker::Lorem.sentence }
    let!(:block) { NoCms::Blocks::Block.create! title: block_title,
      layout: 'title-long_text',
      translations_attributes: [
        { locale: 'es', body: Faker::Lorem.paragraph },
        { locale: 'en', body: Faker::Lorem.paragraph }
      ]
    }

    before(:all) do
      NoCms::Blocks.configure do |config|
        config.block_layouts = {
          'title-long_text' => {
            template: 'title-long_text',
            fields: {
              title: { type: :string, i18n: false },
              body: :text
            }
          }
        }
      end
    end

    subject { NoCms::Blocks::Block.find block.id }

    it "should retrieve the right text for each language" do
      I18n.with_locale(:es) { expect(subject.title).to eq block_title }
      I18n.with_locale(:en) { expect(subject.title).to eq block_title }
    end

  end
end
