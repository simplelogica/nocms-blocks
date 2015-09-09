require 'spec_helper'

describe NoCms::Blocks::Concerns::ModelWithSlots do

  it_behaves_like "model with has many relationship", :slotted_page, :block_slot, :block_slots, :container

  it_behaves_like "model with has many through belongs to relationship",
    :slotted_page, :block_slot, :block, :block_slots, :block, :blocks

  it_behaves_like "model with has many relationship", :block_slot, :block_slot, :children, :parent

end
