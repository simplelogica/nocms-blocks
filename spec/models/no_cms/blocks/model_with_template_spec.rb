require 'spec_helper'

describe NoCms::Blocks::Concerns::ModelWithTemplate do

  context "a model with templates" do

    it "should define its valid templates" do
      expect(SlottedPage.allowed_templates.map(&:name)).to match_array ['default', 'two-columns', 'one_column']
    end

  end


  context "when a page has a valid template" do

    let!(:page) { create :slotted_page, template: 'default' }

    subject { page }

    it "should find its template" do
      expect(subject.template_config).to eq NoCms::Blocks::Template.find('default')
    end

  end

  context "when a page has an non existent template" do

    let!(:page) { build :slotted_page, template: 'fake-template' }

    subject { page }

    it "should not be valid" do
      expect(subject).to_not be_valid
    end

  end

  context "when a page has a non-appliable template" do

    let!(:page) { build :slotted_page, template: 'image' }

    subject { page }

    it "should not be valid" do
      expect(subject).to_not be_valid
    end

  end

end
