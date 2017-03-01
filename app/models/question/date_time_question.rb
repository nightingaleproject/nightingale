require 'date'
# Question Module
module Question
  # DateTime Question Model
  class DateTimeQuestion < Question
    def valid_answer(answer)
      begin
        Date.parse(answer)
        true
      rescue ArgumentError
        false
      end
    end
  end
end
