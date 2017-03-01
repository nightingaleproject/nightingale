class County < ApplicationRecord
  has_many :cities, dependent: :destroy
  belongs_to :state
end
