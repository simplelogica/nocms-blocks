class TestImage < ActiveRecord::Base
  mount_uploader :logo, LogoUploader

  validates :name, presence: true
end
