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

    it "should find a bone within a skeleton" do
      expect(NoCms::Blocks::Skeleton.find('default').bone(:header)).to_not be_nil
      expect(NoCms::Blocks::Skeleton.find('default').bone(:body)).to_not be_nil
      expect(NoCms::Blocks::Skeleton.find('default').bone(:footer)).to_not be_nil
      expect(NoCms::Blocks::Skeleton.find('default').bone(:fake)).to be_nil
    end

  end
end
