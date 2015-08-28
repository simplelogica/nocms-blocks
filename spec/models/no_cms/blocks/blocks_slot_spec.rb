require 'spec_helper'

describe NoCms::Blocks::Block do

  it_behaves_like "model with has many relationship", :slotted_page, :block_slot, :block_slots, :container

end
