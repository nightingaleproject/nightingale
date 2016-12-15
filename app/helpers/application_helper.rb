# Application Helper
module ApplicationHelper
  # helper method for displaying an address
  # optionally expects 'county' and 'apartment_number' arguments
  def display_address(street, city, state, zip_code, options = {})
    county = options[:county]
    apartment_number = options[:apartment_number]

    # the container-fluid style adds some padding that makes it display odd.
    # removed that inline for now.
    # TODO:  Consider updating CSS to properly fix
    content_tag(:table, class: 'container-fluid', style:  'margin-left:0') do
      concat(content_tag(:tr) do
        concat(content_tag(:td, style: 'padding-left:0') do
          concat street
          if apartment_number
            concat ', '
            concat apartment_number
          end
        end)
      end)
      concat(content_tag(:tr) do
        concat(content_tag(:td, style: 'padding-left:0') do
          concat city
          concat ', '
          concat state
          concat ' '
          concat zip_code
        end)
      end)
      if county
        concat(content_tag(:tr) do
          concat(content_tag(:td, style: 'padding-left:0') do
            concat county
          end)
        end)
      end
    end
  end
end
