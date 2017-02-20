class CustomTelInput < SimpleForm::Inputs::StringInput
  def input(wrapper_options = nil)
    merged_input_options = merge_wrapper_options(input_html_options, wrapper_options)
    template.phone_field_tag(attribute_name, nil, merged_input_options)
  end
end