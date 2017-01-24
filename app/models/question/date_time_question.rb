require 'date'

module Question
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