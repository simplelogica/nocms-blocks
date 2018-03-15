require 'spec_helper'

describe NoCms::Blocks::Block do

  before do
    NoCms::Blocks.configure do |config|
      config.block_layouts = {
        'header1' => {
          template: 'header1',
          fields: { }
        },
        'header2' => {
          template: 'header2',
          fields: { }
        },
        'general1' => {
          template: 'general1',
          fields: { }
        },
        'general2' => {
          template: 'general2',
          fields: { }
        },
        'mixed_lazy_block' => {
          template: 'mixed_lazy_block',
          fields: { }
        }
      }
    end
  end

  let(:container) { create :slotted_page, template: 'default' }
  let(:slot) { create(:block_slot, block: block, container: container, template_zone: zone) }
  let(:zone) { 'header' }
  let(:block) { create :block, layout: layout }

  subject { block }

  shared_examples_for "recognizable lazy block" do
    it "should get recognized" do
      expect(slot.template_zone_config.config[:lazy_blocks].map(&:to_s).include?(block.template)).to eq should_be_lazy
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


  context "when a block in the whole template is lazy" do
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

end
