// NightCOD; custom field that asks for Cause of Death information.
class NightCOD extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      immediate: this.props.formData.immediate ? this.props.formData.immediate : '',
      immediateInt: this.props.formData.immediateInt ? this.props.formData.immediateInt : '',
      under1: this.props.formData.under1 ? this.props.formData.under1 : '',
      under1Int: this.props.formData.under1Int ? this.props.formData.under1Int : '',
      under2: this.props.formData.under2 ? this.props.formData.under2 : '',
      under2Int: this.props.formData.under2Int ? this.props.formData.under2Int : '',
      under3: this.props.formData.under3 ? this.props.formData.under3 : '',
      under3Int: this.props.formData.under3Int ? this.props.formData.under3Int : ''
    };
    this.onChange = this.onChange.bind(this);
  }

  onChange(name) {
    return event => {
      this.setState(
        {
          [name]: event.target.value
        },
        () => this.props.onChange(this.state)
      );
    };
  }

  render() {
    return (
      <fieldset className="mt-4 pt-1 pb-2" id={this.props.name + 'field'}>
        <legend>
          {this.props.schema.required && <i className="fa fa-asterisk night-required-icon pb-1 mr-1" />}
          {this.props.schema.title}
        </legend>
        <div className="row mt-1 mb-1">
          <div className="form-group col-md-9">
            <label htmlFor="immediate">Immediate Cause of Death</label>
            <input
              className="form-control"
              type="string"
              value={this.state.immediate}
              id="immediate"
              onChange={this.onChange('immediate')}
            />
          </div>
          <div className="form-group col-md-3">
            <label htmlFor="immediateInt">Onset to Death</label>
            <input
              className="form-control"
              type="string"
              value={this.state.immediateInt}
              id="immediateInt"
              onChange={this.onChange('immediateInt')}
            />
          </div>
        </div>
        <div className="row mt-1 mb-1">
          <div className="form-group col-md-9">
            <label htmlFor="under1">Underlying Cause of Death</label>
            <input
              className="form-control"
              type="string"
              value={this.state.under1}
              id="under1"
              onChange={this.onChange('under1')}
            />
          </div>
          <div className="form-group col-md-3">
            <label htmlFor="under1Int">Onset to Death</label>
            <input
              className="form-control"
              type="string"
              value={this.state.under1Int}
              id="under1Int"
              onChange={this.onChange('under1Int')}
            />
          </div>
        </div>
        <div className="row mt-1 mb-1">
          <div className="form-group col-md-9">
            <label htmlFor="under2">Underlying Cause of Death</label>
            <input
              className="form-control"
              type="string"
              value={this.state.under2}
              id="under2"
              onChange={this.onChange('under2')}
            />
          </div>
          <div className="form-group col-md-3">
            <label htmlFor="under2Int">Onset to Death</label>
            <input
              className="form-control"
              type="string"
              value={this.state.under2Int}
              id="under2Int"
              onChange={this.onChange('under2Int')}
            />
          </div>
        </div>
        <div className="row mt-1 mb-1">
          <div className="form-group col-md-9">
            <label htmlFor="under3">Underlying Cause of Death</label>
            <input
              className="form-control"
              type="string"
              value={this.state.under3}
              id="under3"
              onChange={this.onChange('under3')}
            />
          </div>
          <div className="form-group col-md-3">
            <label htmlFor="under3Int">Onset to Death</label>
            <input
              className="form-control"
              type="string"
              value={this.state.under3Int}
              id="under3Int"
              onChange={this.onChange('under3Int')}
            />
          </div>
        </div>
      </fieldset>
    );
  }
}
