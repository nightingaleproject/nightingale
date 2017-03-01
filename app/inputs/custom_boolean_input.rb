# Custom Boolean Input
class CustomBooleanInput < SimpleForm::Inputs::BooleanInput
  def input
    # Does an answer exist for this question and death record?
    answer = Answer::Answer.find_by(death_record_id: options[:death_record_id], question_id: attribute_name.gsub(/[^\d]/, '').to_i)
    if answer.nil? || answer.answer.nil?
      content = '0'
      checked = false
    else
      content = '1'
      checked = true
    end

    template.check_box_tag(attribute_name, content, checked, options)
  end
end
