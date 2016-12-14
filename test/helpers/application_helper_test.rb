require 'test_helper'
require 'application_helper'

# helper tests
class ApplicationHelperTest < ActionView::TestCase
  test 'should render address without apartment or country' do
    assert_dom_equal '<table class="container-fluid" style="margin-left:0"><tr><td style="padding-left:0">' \
                     '1 fake st.</td></tr><tr><td style="padding-left:0">Test, TS 03030</td></tr></table>',
                     display_address('1 fake st.', 'Test', 'TS', '03030')
  end

  test 'should render address without apartment' do
    assert_dom_equal '<table class="container-fluid" style="margin-left:0"><tr><td style="padding-left:0">' \
                     '1 fake st.</td></tr><tr><td style="padding-left:0">Test, TS 03030</td></tr><tr>' \
                     '<td style="padding-left:0">USA</td></tr></table>',
                     display_address('1 fake st.', 'Test', 'TS', '03030', country: 'USA')
  end

  test 'should render address without country' do
    assert_dom_equal '<table class="container-fluid" style="margin-left:0"><tr><td style="padding-left:0">' \
                     '1 fake st., Apt 101</td></tr><tr><td style="padding-left:0">Test, TS 03030</td></tr></table>',
                     display_address('1 fake st.', 'Test', 'TS', '03030', apartment_number: 'Apt 101')
  end

  test 'should render address with country and apartment' do
    assert_dom_equal '<table class="container-fluid" style="margin-left:0"><tr><td style="padding-left:0">' \
                     '1 fake st., Apt 101</td></tr><tr><td style="padding-left:0">Test, TS 03030</td></tr><tr>' \
                     '<td style="padding-left:0">USA</td></tr></table>',
                     display_address('1 fake st.', 'Test', 'TS', '03030', apartment_number: 'Apt 101', country: 'USA')
  end
end
