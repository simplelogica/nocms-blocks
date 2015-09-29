require 'spec_helper'

describe NoCms::Blocks::Block do

  context "when the partials folder is configured" do

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

        config.front_partials_folder = 'my_app/blocks'
        config.admin_partials_folder = 'my_app/admin/blocks'
      end
    end

    subject { create :block, layout: 'title-long_text' }

    it("should return the right partials") do
      expect(subject.to_partial_path).to eq 'my_app/blocks/title-long_text'
      expect(subject.to_admin_partial_path).to eq 'my_app/admin/blocks/title-long_text'
    end


  end
end
