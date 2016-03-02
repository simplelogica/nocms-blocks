require 'spec_helper'

describe NoCms::Blocks::Template do
  context "when looking for a template" do

    it "should find the declared templates" do
      expect(NoCms::Blocks::Template.find('default')).to_not be_nil
    end

    it "should not find undeclared layouts" do
      expect(NoCms::Blocks::Template.find('this-template-is-not-real')).to be_nil
    end

    it "should find the a template with zones" do
      expect(NoCms::Blocks::Template.find('default').zones).to_not be_blank
      expect(NoCms::Blocks::Template.find('default').zones.count).to eq 3
    end

    it "should find a zone within a template" do
      expect(NoCms::Blocks::Template.find('default').zone(:header)).to_not be_nil
      expect(NoCms::Blocks::Template.find('default').zone(:body)).to_not be_nil
      expect(NoCms::Blocks::Template.find('default').zone(:footer)).to_not be_nil
      expect(NoCms::Blocks::Template.find('default').zone(:fake)).to be_nil
    end

    it "should find the allowed blocks within a zone" do
      expect(NoCms::Blocks::Template.find('default').zone(:header).allowed_layouts).to match_array  [:default, :general1, :general2, :header1, :header2]
      expect(NoCms::Blocks::Template.find('default').zone(:body).allowed_layouts).to match_array  [:default, :general1, :general2, :body]
      expect(NoCms::Blocks::Template.find('default').zone(:footer).allowed_layouts).to match_array  [:default, :general1, :general2]
    end

  end
end
