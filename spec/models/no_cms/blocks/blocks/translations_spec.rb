require 'spec_helper'

describe NoCms::Blocks::Block do

  context "when loading simple translated fields" do
    let(:block_title_es) { Faker::Lorem.sentence }
    let(:block_title_en) { Faker::Lorem.sentence }
    let(:block_no_fallback_field_es) { Faker::Lorem.sentence }
    let(:block_no_fallback_field_en) { Faker::Lorem.sentence }
    let(:block_fallback_field_es) { Faker::Lorem.sentence }
    let(:block_fallback_field_en) { Faker::Lorem.sentence }
    let!(:block) { NoCms::Blocks::Block.create! layout: 'title-long_text',
      translations_attributes: [
        { locale: 'es', title: block_title_es, no_fallback_field: block_no_fallback_field_es, fallback_field: block_fallback_field_es },
        { locale: 'en', title: block_title_en, no_fallback_field: block_no_fallback_field_en, fallback_field: block_fallback_field_en },
        { locale: 'it', title: nil }
      ]
    }

    before(:all) do
      NoCms::Blocks.configure do |config|
        config.block_layouts = {
          'title-long_text' => {
            template: 'title-long_text',
            fields: {
              title: :string,
              no_fallback_field: { type: :string, translated: { fallback_on_blank: false }},
              fallback_field: { type: :string, translated: { fallback_on_blank: false }},
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

    context "when the fallbacks are disabled" do

      before do
        NoCms::Blocks.i18n_fallbacks_enabled = false
      end

      context "and the value in the locale" do

        context "is nil" do

          context "and there's only a fallback locale" do
            before do
              NoCms::Blocks.i18n_fallbacks = :en
            end
            it "should retrieve the value on the fallback locale " do
              I18n.with_locale(:de) { expect(subject.title).to eq nil }
              I18n.with_locale(:it) { expect(subject.title).to eq nil }
            end
          end

          context "and there are various fallback locales" do
            before do
              NoCms::Blocks.i18n_fallbacks = { de: [:en], ca: :es, fr: [:ca, :es] }
              I18n.default_locale = :en
            end
            it "should retrieve the value on the first locale with a translation" do
              I18n.with_locale(:de) { expect(subject.title).to eq nil }
              I18n.with_locale(:ca) { expect(subject.title).to eq nil }
              I18n.with_locale(:fr) { expect(subject.title).to eq nil }
            end

            it "should retrieve the value on the default locale if no fallback is available" do
              I18n.with_locale(:pt) { expect(subject.title).to eq nil }
            end
          end

        end

        context "is blank" do

          let(:block_title_es) { "" }

          before do
            NoCms::Blocks.i18n_fallback_on_blank = true
            NoCms::Blocks::Layout::DEFAULT_FIELD_CONFIGURATION[:translated][:fallback_on_blank] = true
          end

          context "and there's only a fallback locale" do
            it "should retrieve the value on the fallback locale " do
              I18n.with_locale(:es) { expect(subject.title).to eq "" }
            end
          end

        end

      end
    end

    context "when the fallbacks are enabled" do

      before do
        NoCms::Blocks.i18n_fallbacks_enabled = true
      end

      context "but the blank fallbaks are disabled" do

        before do
          NoCms::Blocks.i18n_fallback_on_blank = false
          NoCms::Blocks::Layout::DEFAULT_FIELD_CONFIGURATION[:translated][:fallback_on_blank] = false
        end

        context "and the value in the locale" do

          context "is nil" do

            context "and there's only a fallback locale" do
              before do
                NoCms::Blocks.i18n_fallbacks = :en
              end
              it "should retrieve the value on the fallback locale " do
                I18n.with_locale(:de) { expect(subject.title).to eq block_title_en }
                I18n.with_locale(:it) { expect(subject.title).to eq block_title_en }
              end
            end

            context "and there are various fallback locales" do
              before do
                NoCms::Blocks.i18n_fallbacks = { de: [:en], ca: :es, fr: [:ca, :es] }
                I18n.default_locale = :en
              end
              it "should retrieve the value on the first locale with a translation" do
                I18n.with_locale(:de) { expect(subject.title).to eq block_title_en }
                I18n.with_locale(:ca) { expect(subject.title).to eq block_title_es }
                I18n.with_locale(:fr) { expect(subject.title).to eq block_title_es }
              end

              it "should retrieve the value on the default locale if no fallback is available" do
                I18n.with_locale(:pt) { expect(subject.title).to eq block_title_en }
              end
            end

          end

          context "is blank" do

            let(:block_title_es) { "" }

            context "and there's only a fallback locale" do
              before do
                NoCms::Blocks.i18n_fallbacks = :en
              end

              it "should retrieve the blank value" do
                I18n.with_locale(:es) { expect(subject.title).to eq "" }
              end

              it "should retrieve a fallback value if this field forces the fallback " do
                I18n.with_locale(:ca) { expect(subject.fallback_field).to eq block_fallback_field_en }
              end
            end

            context "and there are various fallback locales" do
              before do
                NoCms::Blocks.i18n_fallbacks = { de: [:en], ca: [:es, :en], fr: [:ca, :es, :en] }
                I18n.default_locale = :en
              end
              it "should retrieve the value on the first locale with a translation" do
                I18n.with_locale(:de) { expect(subject.title).to eq block_title_en }
                I18n.with_locale(:ca) { expect(subject.title).to eq "" }
                I18n.with_locale(:fr) { expect(subject.title).to eq "" }
              end

              it "should retrieve the value on the default locale if no fallback is available" do
                I18n.with_locale(:pt) { expect(subject.title).to eq block_title_en }
              end

              it "should retrieve a fallback value if this field forces the fallback " do
                I18n.with_locale(:ca) { expect(subject.fallback_field).to eq block_fallback_field_es }
              end
            end

          end
        end
      end


      context "and the blank fallbaks are enabled" do

        before do
          NoCms::Blocks.i18n_fallback_on_blank = true
          NoCms::Blocks::Layout::DEFAULT_FIELD_CONFIGURATION[:translated][:fallback_on_blank] = true
        end

        context "and the value in the locale" do

          context "is nil" do

            context "and there's only a fallback locale" do
              before do
                NoCms::Blocks.i18n_fallbacks = :en
              end
              it "should retrieve the value on the fallback locale " do
                I18n.with_locale(:de) { expect(subject.title).to eq block_title_en }
                I18n.with_locale(:it) { expect(subject.title).to eq block_title_en }
              end
            end

            context "and there are various fallback locales" do
              before do
                NoCms::Blocks.i18n_fallbacks = { de: [:en], ca: :es, fr: [:ca, :es] }
                I18n.default_locale = :en
              end
              it "should retrieve the value on the first locale with a translation" do
                I18n.with_locale(:de) { expect(subject.title).to eq block_title_en }
                I18n.with_locale(:ca) { expect(subject.title).to eq block_title_es }
                I18n.with_locale(:fr) { expect(subject.title).to eq block_title_es }
              end

              it "should retrieve the value on the default locale if no fallback is available" do
                I18n.with_locale(:pt) { expect(subject.title).to eq block_title_en }
              end
            end

          end

          context "is blank" do

            let(:block_title_es) { "" }
            let(:block_no_fallback_field_es) { "" }

            context "and there's only a fallback locale" do
              before do
                NoCms::Blocks.i18n_fallbacks = :en
              end
              it "should retrieve the value on the fallback locale " do
                I18n.with_locale(:es) { expect(subject.title).to eq block_title_en }
              end

              it "should retrieve the blank value if this field has no fallback" do
                I18n.with_locale(:es) { expect(subject.no_fallback_field).to be_blank }
              end
            end

            context "and there are various fallback locales" do
              before do
                NoCms::Blocks.i18n_fallbacks = { de: [:en], ca: [:es, :en], fr: [:ca, :es, :en] }
                I18n.default_locale = :en
              end
              it "should retrieve the value on the first locale with a translation" do
                I18n.with_locale(:de) { expect(subject.title).to eq block_title_en }
                I18n.with_locale(:ca) { expect(subject.title).to eq block_title_en }
                I18n.with_locale(:fr) { expect(subject.title).to eq block_title_en }
              end

              it "should retrieve the value on the default locale if no fallback is available" do
                I18n.with_locale(:pt) { expect(subject.title).to eq block_title_en }
              end

              it "should retrieve the blank value if this field has no fallback " do
                I18n.with_locale(:ca) { expect(subject.no_fallback_field).to be_blank }
              end
            end
          end
        end
      end
    end
  end

  context "when we have some untranslated fields" do
    let(:block_title) { Faker::Lorem.sentence }
    let(:block_body_es) { Faker::Lorem.paragraph }
    let(:block_body_en) { Faker::Lorem.paragraph }
    let(:block_body_fr) { Faker::Lorem.paragraph }

    let(:logo_attributes) { attributes_for(:test_image) }
    let(:background_attributes_es) { attributes_for(:test_image) }
    let(:background_attributes_en) { attributes_for(:test_image) }
    let(:background_attributes_fr) { nil }

    let!(:block) { NoCms::Blocks::Block.create! title: block_title,
      logo: logo_attributes,
      layout: 'title-long_text',
      translations_attributes: [
        { locale: 'es', body: block_body_es, background: background_attributes_es },
        { locale: 'en', body: block_body_en, background: background_attributes_en },
        { locale: 'fr', body: block_body_en, background: background_attributes_fr }
      ]
    }

    before do
      NoCms::Blocks.i18n_fallbacks_enabled = true
    end

    before(:all) do

      NoCms::Blocks.configure do |config|
        config.block_layouts = {
          'title-long_text' => {
            template: 'title-long_text',
            fields: {
              title: { type: :string, translated: false },
              body: :text,
              logo:  { type: TestImage, translated: false },
              background:  { type: TestImage, translated: { fallback_on_blank: true } },
            }
          }
        }
      end
    end

    subject { NoCms::Blocks::Block.find block.id }

    it "should fallback to an image with id when locale has no image, not build an empty one" do
      background_fr = I18n.with_locale(:fr) { subject.background }
      expect(background_fr.id).to_not be_nil
    end

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
