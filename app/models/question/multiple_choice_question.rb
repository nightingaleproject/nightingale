module Question
  class MultipleChoiceQuestion < Question
    has_many :choice

    def valid_answer(answer)
      !(answer.nil? || answer.empty?)
    end

    def get_options
      options = '<option></option>'
      multi_options.split(/\s*,\s*/).each do |opt|
        options += '<option>' + ActionView::Base.full_sanitizer.sanitize(opt) + '</option>'
      end
      return options.html_safe
    end
  end
end