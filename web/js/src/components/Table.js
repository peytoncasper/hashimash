import * as React from "react";
import styled from "styled-components";
import axios from "axios";

export const Table = styled.table`
    border-spacing: 0px;
    position: absolute;
    top: 50px;
    left: 50px;
`;

export const Row = styled.tr`
    border-spacing: 0px;
    background-color: #3D5477;
`;

export const ColumnContainer = styled.div`
    width: 100%;
    height: 100%;
    display: flex;
    align-items: center;
    justify-content: center;
`;

export const ApiVersion = styled.td`
    background-color: #364A68;
    width: 35px;
    height: 37px;
    margin: 0px;
    padding: 0px;
    border-spacing: 0px;

`;

export const Icon = styled.td`
    width: 44px;
    height: 37px;
    margin: 0px;
    padding: 0px;
    border-spacing: 0px;
    color: white;
`;

export const BinaryVersion = styled.td`
    width: 76px;
    height: 37px;
    background-color: #364A68;
`;

export const UpgradeButton = styled.button`
    background: none;
    color: white;
    background-color: #425A7E;
    border: none;
    border-radius: 5px;
    margin: 5px;
    padding: 2px 0 0 0;
    font: inherit;
    cursor: pointer;
    outline: inherit;
    width: 20px;
    height: 20px;
    text-align: center;
`;

export const Location = styled.td`
    width: 81px;
    height: 37px;
`;

export const Token = styled.td`
    width: 155px;
    height: 37px;
`;


class TableComponent extends React.Component {

    upgrade(sensorData) {
        axios.post("/api/upgrade",
               sensorData
            )
            .then(function (response) {
                this.setState({
                    sensorData: response.data
                })
            }.bind(this))
            .catch(function (error) {
                console.log("Error upgrading sensor: ", error);
            })
    }

    constructor(props) {
        super(props);
    }

    render() {
        return <Table className="table">
            <thead style={{color: "#ffffff", backgroundColor: "#2D3F5B"}}>
                <tr>
                    <th colSpan="5">
                        <ColumnContainer style={{height: "24px", width: "391px"}}>
                            Fleet
                        </ColumnContainer>
                    </th>
                </tr>
            </thead>
            <tbody>
            {
                Object.keys(this.props.sensorData).map((key, index) => {
                    return <Row key={index}>
                        <ApiVersion className={("apiversion-" + index)}>
                            <ColumnContainer>
                                <div style={{
                                    borderRadius: "50%",
                                    backgroundColor: this.props.sensorData[key][1]["api_version"] === "1.0.1" ? "#1F87C1" : "#39C848",
                                    width: "15px",
                                    height: "15px"
                                }}/>
                            </ColumnContainer>

                        </ApiVersion>
                        <Icon>
                            <ColumnContainer>
                                <svg aria-hidden="true" focusable="false" data-prefix="fas" data-icon="truck-container"
                                     className="svg-inline--fa fa-truck-container fa-w-20" role="img"
                                     xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 512" style={{width: "30px", height: "25px"}}>
                                    <path fill="#ffffff"
                                          d="M621.3 237.3l-58.5-58.5c-12-12-28.3-18.7-45.3-18.7H464c-17.7 0-32 14.3-32 32v144H32c-17.7 0-32 14.3-32 32v27.8c0 40.8 28.7 78.1 69.1 83.5 30.7 4.1 58.3-9.5 74.9-31.7 18.4 24.7 50.4 38.7 85.3 29.7 25.2-6.5 46.1-26.2 54.4-50.8 4.9-14.8 5.4-29.2 2.8-42.4h163.2c-2.7 13.2-2.2 27.6 2.8 42.4 8.4 25.1 29.9 44.9 55.6 51.1 52.8 12.8 100-26.9 100-77.6 0-5.5-.6-10.8-1.6-16H624c8.8 0 16-7.2 16-16v-85.5c0-17.1-6.7-33.3-18.7-45.3zM80 432c-17.6 0-32-14.4-32-32s14.4-32 32-32 32 14.4 32 32-14.4 32-32 32zm128 0c-17.6 0-32-14.4-32-32s14.4-32 32-32 32 14.4 32 32-14.4 32-32 32zm320 0c-17.6 0-32-14.4-32-32s14.4-32 32-32 32 14.4 32 32-14.4 32-32 32zm-48-176v-48h37.5c4.2 0 8.3 1.7 11.3 4.7l43.3 43.3H480zM32 304h336c17.7 0 32-14.3 32-32V64c0-17.7-14.3-32-32-32H32C14.3 32 0 46.3 0 64v208c0 17.7 14.3 32 32 32zM304 80h32v176h-32V80zm-80 0h32v176h-32V80zm-80 0h32v176h-32V80zm-80 0h32v176H64V80z"></path>
                                </svg>
                            </ColumnContainer>
                        </Icon>
                        <BinaryVersion>
                            <ColumnContainer className={("sensorversion-" + index)} style={{color: "#ffffff"}}>
                                {this.props.sensorData[key][1]["sensor_version"]}
                                {
                                    this.props.sensorData[key][1]["sensor_version"] === "1.0.0" ?
                                    <UpgradeButton onClick={() => {this.upgrade(this.props.sensorData[key])}}>
                                        <svg aria-hidden="true" focusable="false" data-prefix="fas" data-icon="arrow-up"
                                             className="svg-inline--fa fa-arrow-up fa-w-14" role="img"
                                             xmlns="http://www.w3.org/2000/svg" viewBox="0 0 448 512" style={{width: "14px", height: "15px"}}>
                                            <path fill="#ffffff"
                                                  d="M34.9 289.5l-22.2-22.2c-9.4-9.4-9.4-24.6 0-33.9L207 39c9.4-9.4 24.6-9.4 33.9 0l194.3 194.3c9.4 9.4 9.4 24.6 0 33.9L413 289.4c-9.5 9.5-25 9.3-34.3-.4L264 168.6V456c0 13.3-10.7 24-24 24h-32c-13.3 0-24-10.7-24-24V168.6L69.2 289.1c-9.3 9.8-24.8 10-34.3.4z"></path>
                                        </svg>
                                    </UpgradeButton> : null
                                }
                            </ColumnContainer>
                        </BinaryVersion>
                        <Location className={("location-" + index)}>
                            <ColumnContainer style={{color: "#ffffff"}}>
                                ({this.props.sensorData[key][1]["location"]["x"]}, {this.props.sensorData[key][1]["location"]["y"]})
                            </ColumnContainer>
                        </Location>
                        <Token className={("secret-" + index)}>
                            <ColumnContainer style={{color: "#ffffff"}}>
                                {this.props.sensorData[key][1]["token"]}
                            </ColumnContainer>
                        </Token>
                    </Row>
                })
            }
            </tbody>
        </Table>
    }
}

export default TableComponent;