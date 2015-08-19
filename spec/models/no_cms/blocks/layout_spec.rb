require 'spec_helper'

describe NoCms::Blocks::Layout do

  context "when looking for a layout" do

    before do
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

    it "should find the declared layouts" do
      expect(NoCms::Blocks::Layout.find('title-long_text')).to_not be_nil
    end

    it "should not find undeclared layouts" do
      expect(NoCms::Blocks::Layout.find('this-layout-is-not-real')).to be_nil
    end

  end

  context "when the layout has configuration" do
    before do
      NoCms::Blocks.configure do |config|
        config.block_layouts = {
          'title-long_text' => {
            template: block_template,
            fields: {
              title: title_configuration[:type],
              column: column_configuration,
              body: body_configuration
            },
            allow_nested_blocks: block_allow_nested_blocks,
            nest_levels: block_nest_levels,
            cache_enabled: block_cache_enabled
          }
        }
      end
    end

    let(:block_template) { 'title-long_text' }
    let(:block_allow_nested_blocks) { true }
    let(:block_nest_levels) { [0,1] }
    let(:block_cache_enabled) { true }
    let(:title_configuration) { { type: :string } }
    let(:column_configuration) { { type: :string, translated: false } }
    let(:body_configuration) { { type: :text, duplicate: :nullify } }

    subject { NoCms::Blocks::Layout.find('title-long_text') }

    it "should recover the configuration for quickly configured fields" do
      expect(subject.fields[:title]).to eq NoCms::Blocks::Layout::DEFAULT_FIELD_CONFIGURATION.merge(title_configuration)
    end

    it "should recover the configuration for verbosing configured fields" do
      expect(subject.fields[:body]).to eq NoCms::Blocks::Layout::DEFAULT_FIELD_CONFIGURATION.merge(body_configuration)
    end

    it "should recover the configuration for a field that overwrites some default configuration" do
      expect(subject.fields[:body]).to eq NoCms::Blocks::Layout::DEFAULT_FIELD_CONFIGURATION.merge(body_configuration)
      expect(subject.fields[:column]).to eq NoCms::Blocks::Layout::DEFAULT_FIELD_CONFIGURATION.merge(column_configuration)
    end

    it "should recover the template from the configuration" do
      expect(subject.template).to eq block_template
    end

    it "should recover the 'allow_nested_blocks' from the configuration" do
      expect(subject.allow_nested_blocks).to eq block_allow_nested_blocks
    end

    it "should recover the nest levels from the configuration" do
      expect(subject.nest_levels).to eq block_nest_levels
    end

    it "should recover the 'cache enabled' setting from the configuration" do
      expect(subject.cache_enabled).to eq block_cache_enabled
    end
  end

  context "when config is empty" do

    before do
      NoCms::Blocks.configure do |config|
        config.block_layouts = {
          'title-long_text' => {
          }
        }
      end
    end

    subject { NoCms::Blocks::Layout.find('title-long_text') }

    it "should recover no fields" do
      expect(subject.fields).to be_empty
    end

    it "should recover no template" do
      expect(subject.template).to be_nil
    end

    it "should recover default 'allow_nested_blocks' setting " do
      expect(subject).to_not be_allow_nested_blocks
    end

    it "should recover no nest levels" do
      expect(subject.nest_levels).to be_empty
    end

    it "should recover the global 'cache enabled' setting" do
      expect(subject.cache_enabled).to eq NoCms::Blocks.cache_enabled
    end

  end

end
