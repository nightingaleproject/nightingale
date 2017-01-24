class CustomTextInput < SimpleForm::Inputs::StringInput
  def input(wrapper_options = nil)
    # Does an answer exist for this question and death record?
    answer = Answer::Answer.find_by(death_record_id: options[:death_record_id], question_id: attribute_name.gsub(/[^\d]/, '').to_i)
    unless answer.nil? || answer.answer.nil?
      content = answer.answer
    else
      content = ''
    end

    merged_input_options = merge_wrapper_options(input_html_options, wrapper_options)
    template.text_field_tag(attribute_name, content, merged_input_options)
  end
end