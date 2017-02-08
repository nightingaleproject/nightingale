class CustomDatetimeInput < SimpleForm::Inputs::DateTimeInput
  def input(wrapper_options = nil)
    # Does an answer exist for this question and death record?
    answer = Answer::Answer.find_by(death_record_id: options[:death_record_id], question_id: attribute_name.gsub(/[^\d]/, '').to_i)
    if answer.nil? || answer.answer.nil?
      content = ''
    else
      content = answer.answer
    end

    template.datetime_field_tag(attribute_name, content, options)
  end

end