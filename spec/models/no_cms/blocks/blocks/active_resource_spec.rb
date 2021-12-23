require 'spec_helper'

describe NoCms::Blocks::Block do

  context "when a field has an ActiveResource element" do

    before do

      NoCms::Blocks.configure do |config|
        config.block_layouts['country'] = {
          template: 'country',
          fields: {
            country: Country,
            borders: { type: Country, multiple: true }
          }
        }
      end

    end


    subject { block }

    context "concerning single ActiveResource fields" do
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
          expect_any_instance_of(Country).to receive(:save).at_least(:once).and_return(true)
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
    context "concerning multiple ActiveResource fields" do

      context "when the AR field is already stored" do

        # We mock the Country model so we don't have to query any API
        before do
          expect(Country).to receive(:find_all).with([1,2]).once.and_return([country_1, country_2])
        end

        let(:country_1) { build(:country) }
        let(:country_2) { build(:country) }
        let(:block) { NoCms::Blocks::Block.create attributes_for(:block).merge(
            layout: 'country',
            borders_ids:[1, 2]
          )
        }

        it("should respond to layout fields") do
          expect{subject.borders}.to_not raise_error
          expect{subject.borders_ids}.to_not raise_error
        end

        it("should respond to the active resource fields") do
          expect(subject.borders).to match_array [country_1, country_2]
        end

      end

      context "when the AR field is created through the attributes" do

        before do
          allow_any_instance_of(Country).to receive(:save).and_return(true)
          allow_any_instance_of(Country).to receive(:id) { Time.now.to_i }
          expect(Country).to receive(:find_all).and_return([country_1, country_2])
        end

        let(:country_1_attributes) { attributes_for(:country).merge( fake_id: 1) }
        let(:country_2_attributes) { attributes_for(:country).merge( fake_id: 2) }
        let(:country_1) { build(:country, country_1_attributes.merge(id: 1)) }
        let(:country_2) { build(:country, country_2_attributes.merge(id: 2)) }

        let(:block) { NoCms::Blocks::Block.create attributes_for(:block).merge(
            layout: 'country',
            borders: [country_1_attributes, country_2_attributes]
          )
        }

        before do
          subject.reload
        end

        it("should respond to layout fields") do
          expect{subject.borders}.to_not raise_error
          expect{subject.borders_ids}.to_not raise_error
        end

        it("should return objects") do
          expect(subject.borders).to be_a(Array)
          expect(subject.borders.first).to be_a(Country)
        end

        it("should return objects with the right value") do
          expect(subject.borders.first.name).to eq country_1_attributes[:name]
        end

      end
    end

  end



end
