# State Model
class Geography::State < ApplicationRecord
  has_many :counties, dependent: :destroy
  has_many :cities, dependent: :destroy
  has_many :zipcodes, dependent: :destroy
end
