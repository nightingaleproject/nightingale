# Question Module
module Question
  # StringQuestion Model
  class StringQuestion < Question
    def valid_answer(answer)
      !(answer.nil? || answer.empty?)
    end
  end
end
