# Statistics Module for helping with building charts
module StatisticsHelper
  # Helper function that creates the line_chart for the view after calling "by_day" in the charts_controller
  def stat_by(start_date, end_date, query_action)
    start_date ||= 1.month.ago
    end_date ||= Time.current
    if params[:query_action].blank?
      query_action ||= 'death_records_created'
    else
      query_action = params[:query_action]
    end
    line_chart by_day_charts_path(start_date: start_date, end_date: end_date, query_action: query_action), basic_opts(query_action.titleize, start_date, end_date)
  end

  private

  # Helper function that builds the settings we pass into the line chart.
  def basic_opts(title, start_date, end_date)
    {
      discrete: true,
      library: {
        title: { text: title, x: -20 },
        subtitle: { text: "from #{DatetimeHelper.pretty_datetime(start_date)} to #{DatetimeHelper.pretty_datetime(end_date)}", x: -20 },
        yAxis: {
          title: {
            text: 'Count'
          }
        },
        tooltip: {
          valueSuffix: ' item(s)'
        },
        credits: {
          enabled: false
        }
      }
    }
  end
end
