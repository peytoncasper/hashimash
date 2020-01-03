import * as React from "react";
import styled from "styled-components";

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

export const Location = styled.td`
    width: 81px;
    height: 37px;
`;


class TableComponent extends React.Component {

    constructor(props) {
        super(props);
    }

    render() {
        return <Table>
            <thead style={{color: "#ffffff", backgroundColor: "#2D3F5B"}}>
                <tr>
                    <th colSpan="4">
                        <ColumnContainer style={{height: "24px", width: "236px"}}>
                            Fleet
                        </ColumnContainer>
                    </th>
                </tr>
            </thead>
            <tbody>
            {
                Object.keys(this.props.sensorData).map((key, index) => {
                    return <Row key={index}>
                        <ApiVersion >
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
                                <i className="fas fa-truck-container"/>
                            </ColumnContainer>
                        </Icon>
                        <BinaryVersion>
                            <ColumnContainer style={{color: "#ffffff"}}>
                                {this.props.sensorData[key][1]["sensor_version"]}
                            </ColumnContainer>
                        </BinaryVersion>
                        <Location>
                            <ColumnContainer style={{color: "#ffffff"}}>
                                ({this.props.sensorData[key][1]["location"]["x"]}, {this.props.sensorData[key][1]["location"]["y"]})
                            </ColumnContainer>
                        </Location>
                    </Row>
                })
            }
            </tbody>
        </Table>
    }
}

export default TableComponent;