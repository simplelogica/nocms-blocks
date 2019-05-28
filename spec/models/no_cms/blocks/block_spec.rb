require 'spec_helper'

describe NoCms::Blocks::Block do

  it_behaves_like "model with required attributes", :block, [:layout]
  it_behaves_like "model with has many relationship", :block, :block_slot, :slots, :block

end
