require 'spec_helper'

describe NoCms::Blocks::Concerns::ModelWithTemplate do

  before do
    NoCms::Blocks.configure do |config|
      config.templates = {
        'default' => {
          blocks: [:general1, :general2],
          zones: {
            header: {
              blocks: [:header1, :header2]
            },
            body: {
              blocks: [:body]
            },
            footer: {
            }
          }
        }
      }
    end
  end

  context "a model with templates" do

    it "should define its valid templates" do
      expect(SlottedPage.allowed_templates).to match_array ['default']
    end

  end


  context "when a page has a valid template" do

    let!(:page) { create :slotted_page, template: 'default' }

    subject { page }

    it "should find its template" do
      expect(subject.template_config).to eq NoCms::Blocks::Template.find('default')
    end

  end

  context "when a page has an invalid template" do

    let!(:page) { build :slotted_page, template: 'fake-template' }

    subject { page }

    it "should not be valid" do
      expect(subject).to_not be_valid
    end

  end
end
