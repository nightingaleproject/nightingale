# Custom Multi Input
class CustomMultipleInput < SimpleForm::Inputs::CollectionSelectInput
  def input(wrapper_options = nil)
    # Get multiple choice options
    question_id = attribute_name.gsub(/[^\d]/, '').to_i
    question = Question::MultipleChoiceQuestion.find(question_id)

    merged_input_options = merge_wrapper_options(input_html_options, wrapper_options)
    template.select_tag(attribute_name, question.get_options, merged_input_options)
  end
end
