require 'spec_helper'

describe NoCms::Blocks::Skeleton do
  context "when looking for a skeleton" do

    before do
      NoCms::Blocks.configure do |config|
        config.skeletons = {
          'default' => {
            bones: {
              header: {
              },
              body: {
              },
              footer: {
              }
            }
          }
        }
      end
    end

    it "should find the declared skeletons" do
      expect(NoCms::Blocks::Skeleton.find('default')).to_not be_nil
    end

    it "should not find undeclared layouts" do
      expect(NoCms::Blocks::Skeleton.find('this-skeleton-is-not-real')).to be_nil
    end

    it "should find the a skeleton with bones" do
      expect(NoCms::Blocks::Skeleton.find('default').bones).to_not be_blank
      expect(NoCms::Blocks::Skeleton.find('default').bones.count).to eq 3
    end

  end
end
