require 'spec_helper'

describe NoCms::Blocks::Block do

  before do
    NoCms::Blocks.configure do |config|
      config.block_layouts = {
        'header1' => {
          template: 'default',
          fields: {
            title: :string
          }
        },
        'header2' => {
          template: 'default',
          skeleton_template: header_2_skeleton_template,
          fields: {
            title: :string
          }
        },
        'general1' => {
          template: 'default',
          fields: {
            title: :string
          }
        },
        'general2' => {
          template: 'default',
          fields: {
            title: :string
          }
        },
        'mixed_lazy_block' => {
          template: 'default',
          fields: {
            title: :string
          }
        }
      }
    end
  end

  let(:header_2_skeleton_template) { 'header_2_lazy' }

  let(:container) { create :slotted_page, template: 'default' }
  let(:slot) { create(:block_slot, block: block, container: container, template_zone: zone) }
  let(:zone) { 'header' }
  let(:block) { create :block, layout: layout }

  subject { block }

  shared_examples_for "recognizable lazy block" do
    it "should get recognized" do
      expect(slot.template_zone_config.is_lazy_layout?(block.layout)).to eq should_be_lazy
    end
  end


  context "when a block in a zone is lazy" do
    let(:layout) { 'header2' }
    let(:should_be_lazy) { true }

    it_behaves_like "recognizable lazy block"

  end

  context "when a block in the whole template is lazy" do
    let(:layout) { 'general2' }
    let(:should_be_lazy) { true }

    it_behaves_like "recognizable lazy block"

  end


  context "when a block in a zone is not lazy" do
    let(:layout) { 'header1' }
    let(:should_be_lazy) { false }

    it_behaves_like "recognizable lazy block"

  end


  context "when a block in the whole template is not lazy" do
    let(:layout) { 'general1' }
    let(:should_be_lazy) { false }

    it_behaves_like "recognizable lazy block"

  end

  context "when a mixed block is in a zone where it's lazy" do
    let(:layout) { 'mixed_lazy_block' }
    let(:should_be_lazy) { true }

    it_behaves_like "recognizable lazy block"

  end

  context "when a mixed block is in a zone where it's not lazy" do
    let(:layout) { 'mixed_lazy_block' }
    let(:should_be_lazy) { false }
    let(:zone) { 'body' }

    it_behaves_like "recognizable lazy block"

  end

  context "when a block has skeleton template" do

    let(:layout) { 'header2' }


    it "should have a customized skeleton path" do
      expect(subject.to_skeleton_path).to eq "#{NoCms::Blocks.front_skeletons_folder}/#{header_2_skeleton_template}"
    end
  end

  context "when a block has no skeleton template" do

    let(:layout) { 'header1' }


    it "should have a customized skeleton path" do
      expect(subject.to_skeleton_path).to eq "#{NoCms::Blocks.front_skeletons_folder}/default"
    end
  end
end
