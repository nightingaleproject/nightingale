// DashboardCharts component; makes up the charts on the dashboard view.
class DashboardCharts extends React.Component {
  constructor(props) {
    super(props);
  }

  componentDidMount() {
    // Draw death record age pie chart
    $.post(Routes.pie_death_record_ages_by_range_statistics_path(), function(data, status) {
      $('#pie_death_record_ages_by_range').replaceWith(data);
    });
    // Draw death record completion time bar chart
    $.post(Routes.bar_average_completion_statistics_path(), function(data, status) {
      $('#bar_average_completion').replaceWith(data);
    });
  }

  render() {
    return (
      <div className="row mt-1 mb-5">
        <div className="col-md-6 pl-0">
          <div className="card text-center night-full-height">
            <div className="card-header">Age of Open Records</div>
            <div className="card-block">
              <div id="pie_death_record_ages_by_range" />
            </div>
          </div>
        </div>
        <div className="col-md-6 pr-0">
          <div className="card text-center night-full-height">
            <div className="card-header">Average Step Completion Time</div>
            <div className="card-block">
              <div id="bar_average_completion" />
            </div>
          </div>
        </div>
      </div>
    );
  }
}
