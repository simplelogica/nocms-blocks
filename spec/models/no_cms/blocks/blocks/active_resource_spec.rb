require 'spec_helper'

describe NoCms::Blocks::Block do

  context "when a field has an ActiveResource element" do

    before do

      NoCms::Blocks.configure do |config|
        config.block_layouts['country'] = {
          template: 'country',
          fields: {
            country: Country
          }
        }
      end

    end


    subject { block }

    context "when the AR field is already stored" do

      # We mock the Country model so we don't have to query any API
      before do
        allow(Country).to receive(:find).with(1).and_return(country)
      end

      let(:country) { build(:country) }
      let(:block) { NoCms::Blocks::Block.create attributes_for(:block).merge(
          layout: 'country',
          country_id: 1
        )
      }

      it("should respond to the active resource fields") do
        expect(subject.country).to eq country
      end

    end

    context "when the AR field is created through the attributes" do

      # We mock the Country model so we don't have to query any API
      before do
        allow(Country).to receive(:build).and_return(build(:country))
        expect_any_instance_of(Country).to receive(:save).exactly(2).times.and_return(true)
      end

      let(:country_attributes) { attributes_for(:country) }
      let(:block) { NoCms::Blocks::Block.create attributes_for(:block).merge(
          layout: 'country',
          country: country_attributes
        )
      }

      it("should respond to layout fields") do
        expect{subject.country}.to_not raise_error
        expect{subject.country_id}.to_not raise_error
      end

      it("should return objects") do
        expect(subject.country).to be_a(Country)
      end

      it("should return objects with the right value") do
        expect(subject.country.name).to eq country_attributes[:name]
      end

    end

  end



end
