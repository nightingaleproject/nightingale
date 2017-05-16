# Zipcode Model
class Zipcode < ApplicationRecord
  belongs_to :state
  belongs_to :county
  belongs_to :city
end
