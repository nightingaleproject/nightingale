class State < ApplicationRecord
  has_many :counties, dependent: :destroy
  has_many :cities, dependent: :destroy
end
