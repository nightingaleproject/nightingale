class CustomMultipleInput < SimpleForm::Inputs::CollectionSelectInput
  def input(wrapper_options = nil)
    # Get multiple choice options
    question_id = attribute_name.gsub(/[^\d]/, '').to_i
    question = Question::MultipleChoiceQuestion.find(question_id)

    # Does an answer exist for this question and death record?
    answer = Answer::Answer.find_by(death_record_id: options[:death_record_id], question_id: question_id)
    unless answer.nil? || answer.answer.nil? || answer.answer.empty?
      selected = answer.answer
    else
      selected = ''
    end

    merged_input_options = merge_wrapper_options(input_html_options, wrapper_options)
    template.select_tag(attribute_name, question.get_options, merged_input_options)
  end
end