require 'test_helper'

class DatetimeHelperTest < ActiveSupport::TestCase
  setup do
    @datetime_nil = nil
    @datetime = DateTime.new(2001,2,3,4,5,6)
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
    assert_equal 'Feb 02, 2001 11:05 PM', DatetimeHelper.pretty_datetime(@datetime)
  end

  test 'generate pretty date' do
    assert_equal 'Feb. 02, 2001', DatetimeHelper.pretty_date(@datetime)
  end

  test 'generate pretty time' do
    assert_equal '10:19 AM', DatetimeHelper.pretty_time(@time)
  end

end
