# Question Module
module Question
  # Question Model
  class Question < ApplicationRecord
    has_many :answer
    accepts_nested_attributes_for :answer
  end
end
