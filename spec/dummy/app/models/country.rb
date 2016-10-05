class Country < ActiveResource::Base
  self.site = 'http://localhost:3000'

  def self.find id
    self.new id: id, name: Faker::Lorem.name
  end

  def self.build
    self.new name: nil
  end

  def self.find_all ids
    ids.map{|id| find id }
  end

  def save
    self.persisted = true
    true
  end

end
