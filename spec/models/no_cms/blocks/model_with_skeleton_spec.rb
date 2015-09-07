require 'spec_helper'

describe NoCms::Blocks::Concerns::ModelWithSkeleton do

  before do
    NoCms::Blocks.configure do |config|
      config.skeletons = {
        'default' => {
          blocks: [:general1, :general2],
          bones: {
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

  context "a model with skeletons" do

    it "should define its valid skeletons" do
      expect(SlottedPage.allowed_skeletons).to match_array ['default']
    end

  end


  context "when a page has a valid skeleton" do

    let!(:page) { create :slotted_page, skeleton: 'default' }

    subject { page }

    it "should find its skeleton" do
      expect(subject.skeleton_config).to eq NoCms::Blocks::Skeleton.find('default')
    end

  end

  context "when a page has an invalid skeleton" do

    let!(:page) { build :slotted_page, skeleton: 'fake-skeleton' }

    subject { page }

    it "should not be valid" do
      expect(subject).to_not be_valid
    end

  end
end
