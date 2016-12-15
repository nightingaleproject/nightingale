# Application Helper
module ApplicationHelper
  # helper method for displaying an address
  # optionally expects 'country', 'county', and 'apartment_number' arguments
  #
  # displays address like:
  #
  # 123 Test St., Apt 10
  # City, ST 02020, Test County
  # Country
  def display_address(street, city, state, zip_code, options = {})
    country = options[:country]
    apartment_number = options[:apartment_number]
    county = options[:county]

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
          if county
            concat ', '
            concat county
          end
        end)
      end)
      if country
        concat(content_tag(:tr) do
          concat(content_tag(:td, style: 'padding-left:0') do
            concat country
          end)
        end)
      end
    end
  end
end
