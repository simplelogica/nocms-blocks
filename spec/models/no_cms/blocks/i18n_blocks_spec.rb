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

    # before { block.save! }

    subject { NoCms::Blocks::Block.find block.id }

    it "should have retrieve the right text for each language" do
      I18n.with_locale(:es) { expect(subject.title).to eq block_title_es }
      I18n.with_locale(:en) { expect(subject.title).to eq block_title_en }
    end
  end
end
