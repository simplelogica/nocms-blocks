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

  context "when a page has a valid skeleton" do

    let!(:page) { create :slotted_page, skeleton: 'default' }

    subject { page }

    it "should find its skeleton" do
      expect(subject.skeleton_config.config).to eq NoCms::Blocks::Skeleton.find('default').config
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
