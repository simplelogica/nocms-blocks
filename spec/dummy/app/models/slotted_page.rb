class SlottedPage < ActiveRecord::Base
  include NoCms::Blocks::Concerns::ModelWithSlots
end
