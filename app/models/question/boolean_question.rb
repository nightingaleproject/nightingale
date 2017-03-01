# Question Module
module Question
  # Boolean Question Model
  class BooleanQuestion < Question
    def valid_answer
      true
    end
  end
end
