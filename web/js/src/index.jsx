import * as React from 'react'
import ReactDOM from 'react-dom';
import WorldComponent, {World} from "./components/World";
import TableComponent, {Table} from "./components/Table";
import Joyride from 'react-joyride';
import './scss/Root.scss';
import axios from 'axios';
import styled from "styled-components";

const Footer = styled.div`
    flex: 0 1 auto;
`;

const Content = styled.div`
    width: 100vw;
    display: flex;
    flex-direction: row;
    align-items: center;
    justify-content: center;
`;

const StartTourButton = styled.button`
    background: none;
    color: white;
    background-color: rgb(255, 0, 68);
    border: none;
    border-radius: 5px;
    margin: 15px;
    padding: 2px 0 0 0;
    font: inherit;
    cursor: pointer;
    outline: inherit;
    width: 100px;
    height: 35px;
    text-align: center;
`;

class RootComponent extends React.Component {

  constructor(props) {
    super(props);

    this.state = {
      sensorData: {},
      run: false,
      steps: [
        {
          target: 'body',
          content: 'Hashimash is a fictional fleet management application that collects telemetry about internet connected trucks by using a combination of Consul, Nomad, Vault and Terraform.',
          title: "Welcome!",
          placement: 'center',
          disableBeacon: true
        },
        {
          target: '.world',
          content: 'This 3x3 map represents the current position of each simulated truck that is sending telemetry back. Consul creates the connection between each Sensor and the backend API over WAN. This allows them to communicate securely across the public internet and reach services within Kubernetes without exposing them via Load Balancers',
          title: "The World Map",
          disableBeacon: true,
          placement: 'right'
        },
        {
          target: '.table',
          content: 'The Fleet Details table specific information about each truck that is streaming telemetry',
          title: "Details",
          disableBeacon: true
        },
        {
          target: '.apiversion-0',
          content: 'Consul is used to provide Canary deployments with automatic load splitting. This indicates which API version a truck has most recently contacted. In this case, there are two versions represented by Blue and Green.',
          title: "API Version",
          disableBeacon: true
        },
        {
          target: '.sensorversion-0',
          content: "Nomad is utilized as a light weight scheduler that pulls configuration values from Consul's KV storage. This allows us to remotely trigger binary updates which causes Nomad to update and reschedule the new binary. The visibility of the upgrade button indicates whether or not there is an available update for the given truck.",
          title: "Binary Version",
          disableBeacon: true
        },
        {
          target: '.location-0',
          content: "Consul's KV storage is utilized in this scenario to store the telemetry data from each truck. The individual truck location's on the 3x3 grid are showcased here.",
          title: "Location",
          disableBeacon: true
        },
        {
          target: '.secret-0',
          content: "Vault Secret Management is utilized to store an API token when the API servers are scheduled. The individual trucks will look for this secret from Vault and pass it along with the telemetry data which provides as a simple authentication mechanism.",
          title: "Shhh..... Secrets!",
          disableBeacon: true
        },
      ]
    }
  }

  handleStartTour() {
    this.setState({
      run: true,
    });
  }

  componentWillUnmount() {
    clearInterval(this.dataPoll);
  }

  componentDidMount() {
    this.dataPoll = setInterval(this.fetchSensorData.bind(this), 1000);
  }

  fetchSensorData() {
    axios.get("/api")
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
    const { run, steps } = this.state;
    return <div style={{height: "100vh", display: "flex", flexDirection: "column"}}>
      <Joyride
          steps={steps}
          run={run}
          continuous={true}
          showProgress={true}
      />
      <TableComponent sensorData={this.state.sensorData}/>
      <WorldComponent sensorData={this.state.sensorData}/>
      <Footer className="footer">
        <Content>
          <StartTourButton onClick={() => {this.handleStartTour()}}>
            Start Tour
          </StartTourButton>
        </Content>
      </Footer>
    </div>;
  }
}

ReactDOM.render(
  <RootComponent/>,
  document.getElementById('root')
);