class SlottedPage < ActiveRecord::Base
  include NoCms::Blocks::Concerns::ModelWithSlots
  include NoCms::Blocks::Concerns::ModelWithTemplate
end
