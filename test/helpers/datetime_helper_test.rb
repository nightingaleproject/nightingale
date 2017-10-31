require 'test_helper'

class DatetimeHelperTest < ActiveSupport::TestCase
  setup do
    @datetime_nil = nil
    @datetime = DateTime.parse('3rd Feb 2001 11:05:00+00:00')
    @time = Time.new(2015, 12, 8, 10, 19)
    @date_nil = nil
    @time_nil = nil
  end

  test 'nil datetime' do
    assert_equal '', DatetimeHelper.pretty_datetime(@datetime_nil)
  end

  test 'nil date' do
    assert_equal '', DatetimeHelper.pretty_date(@datetime_nil)
  end

  test 'nil time' do
    assert_equal '', DatetimeHelper.pretty_time(@time_nil)
  end

  test 'generate pretty datetime' do
    # This one is tricky due to locale.
    assert DatetimeHelper.pretty_datetime(@datetime).include? 'Feb 03, 2001'
  end

  test 'generate pretty date' do
    assert_equal 'Feb. 03, 2001', DatetimeHelper.pretty_date(@datetime)
  end

  test 'generate pretty time' do
    assert_equal '10:19 AM', DatetimeHelper.pretty_time(@time)
  end

end
