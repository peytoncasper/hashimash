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
    display: flex;
    flex-direction: row;
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
        <Content/>
        <Content>
          <StartTourButton onClick={() => {this.handleStartTour()}}>
            Start Tour
          </StartTourButton>
        </Content>
        <Content style={{justifyContent: "flex-end"}}>
          <a href="https://github.com/peytoncasper/hashimash" target="_blank">

            <svg aria-hidden="true" focusable="false" data-prefix="fab" data-icon="github"
                 className="svg-inline--fa fa-github fa-w-16" role="img" xmlns="http://www.w3.org/2000/svg"
                 viewBox="0 0 496 512" style={{width: "35px", height: "35px", marginRight: "20px"}}>
                <path fill="#ffffff"
                      d="M165.9 397.4c0 2-2.3 3.6-5.2 3.6-3.3.3-5.6-1.3-5.6-3.6 0-2 2.3-3.6 5.2-3.6 3-.3 5.6 1.3 5.6 3.6zm-31.1-4.5c-.7 2 1.3 4.3 4.3 4.9 2.6 1 5.6 0 6.2-2s-1.3-4.3-4.3-5.2c-2.6-.7-5.5.3-6.2 2.3zm44.2-1.7c-2.9.7-4.9 2.6-4.6 4.9.3 2 2.9 3.3 5.9 2.6 2.9-.7 4.9-2.6 4.6-4.6-.3-1.9-3-3.2-5.9-2.9zM244.8 8C106.1 8 0 113.3 0 252c0 110.9 69.8 205.8 169.5 239.2 12.8 2.3 17.3-5.6 17.3-12.1 0-6.2-.3-40.4-.3-61.4 0 0-70 15-84.7-29.8 0 0-11.4-29.1-27.8-36.6 0 0-22.9-15.7 1.6-15.4 0 0 24.9 2 38.6 25.8 21.9 38.6 58.6 27.5 72.9 20.9 2.3-16 8.8-27.1 16-33.7-55.9-6.2-112.3-14.3-112.3-110.5 0-27.5 7.6-41.3 23.6-58.9-2.6-6.5-11.1-33.3 2.6-67.9 20.9-6.5 69 27 69 27 20-5.6 41.5-8.5 62.8-8.5s42.8 2.9 62.8 8.5c0 0 48.1-33.6 69-27 13.7 34.7 5.2 61.4 2.6 67.9 16 17.7 25.8 31.5 25.8 58.9 0 96.5-58.9 104.2-114.8 110.5 9.2 7.9 17 22.9 17 46.4 0 33.7-.3 75.4-.3 83.6 0 6.5 4.6 14.4 17.3 12.1C428.2 457.8 496 362.9 496 252 496 113.3 383.5 8 244.8 8zM97.2 352.9c-1.3 1-1 3.3.7 5.2 1.6 1.6 3.9 2.3 5.2 1 1.3-1 1-3.3-.7-5.2-1.6-1.6-3.9-2.3-5.2-1zm-10.8-8.1c-.7 1.3.3 2.9 2.3 3.9 1.6 1 3.6.7 4.3-.7.7-1.3-.3-2.9-2.3-3.9-2-.6-3.6-.3-4.3.7zm32.4 35.6c-1.6 1.3-1 4.3 1.3 6.2 2.3 2.3 5.2 2.6 6.5 1 1.3-1.3.7-4.3-1.3-6.2-2.2-2.3-5.2-2.6-6.5-1zm-11.4-14.7c-1.6 1-1.6 3.6 0 5.9 1.6 2.3 4.3 3.3 5.6 2.3 1.6-1.3 1.6-3.9 0-6.2-1.4-2.3-4-3.3-5.6-2z"></path>
            </svg>
          </a>

        </Content>
      </Footer>
    </div>;
  }
}

ReactDOM.render(
  <RootComponent/>,
  document.getElementById('root')
);