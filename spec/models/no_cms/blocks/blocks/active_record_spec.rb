require 'spec_helper'

describe NoCms::Blocks::Block do

  context "when blocks have layouts" do

    context "with related models" do

      before do
        NoCms::Blocks.configure do |config|
          config.block_layouts = {
            'logo-caption' => {
              template: 'logo_caption',
              fields: {
                caption: :string,
                logo: TestImage,
                slides: { type: TestImage, multiple: true }
              }
            }
          }
        end
      end

      let(:image_attributes) { attributes_for(:test_image) }

      let(:block_with_layout) { NoCms::Blocks::Block.create attributes_for(:block).merge(
          layout: 'logo-caption',
          caption: Faker::Lorem.sentence,
          logo: image_attributes
        )
      }

      before { subject }
      subject { block_with_layout }

      it("should respond to layout fields") do
        expect{subject.caption}.to_not raise_error
        expect{subject.logo}.to_not raise_error
        expect{subject.logo_id}.to_not raise_error
      end

      it("should return objects") do
        expect(subject.logo).to be_a(TestImage)
      end

      it("should return objects with the right value") do
        expect(subject.logo.name).to eq image_attributes[:name]
      end

      it("should save related objects") do
        expect(TestImage.first).to_not be_nil
      end

      context "when related objects are modified outside" do

        let(:logo) { TestImage.first }
        let(:new_testing_name) { "new testing name" }

        before do
          subject
          logo.update_attribute :name, new_testing_name
        end

        it("should get those modifications") do
          expect(subject.reload.logo.name).to eq new_testing_name
        end

        it("should not overwrite those modifications") do
          subject.save!
          expect(logo.reload.name).to eq new_testing_name
        end

      end

      context "when we update the related object" do

        let(:logo) { TestImage.first }
        let(:new_testing_name) { "new testing name" }
        let(:new_image_attributes) { attributes_for(:test_image,:second_image) }

        before do
          subject.update_attributes logo: { name: new_testing_name, logo: new_image_attributes[:logo] }
        end

        it("should be modified in database") do
          expect(logo.name).to eq new_testing_name
        end

        it("should modify uploaded files") do
          expect(logo[:logo]).to eq File.basename(new_image_attributes[:logo].path)
        end

      end

      context "when the related object is not valid" do

        let(:logo) { TestImage.first }
        let(:new_testing_caption) { "new testing caption" }

        before do
          subject.update_attributes caption: new_testing_caption, logo: { name: nil }
        end

        it("should modify the block attribute") do
          expect(subject.reload.caption).to eq new_testing_caption
        end

        it("should not save the invalid objects") do
          expect(subject.logo.reload.name).to_not be_nil
        end

      end

      context "when we change the image object" do

        let(:new_logo) { create(:test_image) }

        let(:logo) { TestImage.first }

        before do
          subject.update_attribute :logo_id, new_logo.id
        end

        it("should store the new association") do
          expect(subject.reload.logo).to eq new_logo
        end

      end

    end

  end

end
