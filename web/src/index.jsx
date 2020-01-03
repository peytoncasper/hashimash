import * as React from 'react'
import ReactDOM from 'react-dom';
import WorldComponent, {World} from "./components/World";
import TableComponent, {Table} from "./components/Table";
import './scss/Root.scss';
import axios from 'axios';

class RootComponent extends React.Component {

  constructor(props) {
    super(props);

    this.state = {
      sensorData: {}
    }
  }


  componentWillUnmount() {
    clearInterval(this.dataPoll);
  }

  componentDidMount() {
    this.dataPoll = setInterval(this.fetchSensorData.bind(this), 1000);
  }

  fetchSensorData() {
    axios.get("http://localhost")
        .then(function (response) {
          this.setState({
            sensorData: response.data
          })
        }.bind(this))
        .catch(function (error) {
          console.log("Error fetching sensor data: ", error);
        })
  }

  render() {
    return <div style={{height: "100vh"}}>
      <TableComponent sensorData={this.state.sensorData}/>
      <WorldComponent sensorData={this.state.sensorData}/>
    </div>;
  }
}

ReactDOM.render(
  <RootComponent/>,
  document.getElementById('root')
);