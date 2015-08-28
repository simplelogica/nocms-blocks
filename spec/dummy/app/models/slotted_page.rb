class SlottedPage < ActiveRecord::Base
  has_many :block_slots, as: :container
end
