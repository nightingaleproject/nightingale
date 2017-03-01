# City Model
class City < ApplicationRecord
  has_many :zipcodes, dependent: :destroy
  belongs_to :county
  belongs_to :state
end
