import * as React from "react";
import styled from "styled-components";
import {Table} from "./Table";

export const Layer1 = styled.canvas`
  width: 500px;
  height: 500px;
  background: transparent;
  position: absolute;
`;

export const World = styled.div`
  width: 100%;
  height: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
`;


class WorldComponent extends React.Component {
    constructor() {
        super();
        this.images = {
            "bus_01": "assets/bus_01.png",
            "bus_03": "assets/bus_03.png",
            "bus_05": "assets/bus_05.png",
            "bus_07": "assets/bus_07.png",
            "road_03": "assets/road_03.png",
            "road_04": "assets/road_04.png",
            "road_05": "assets/road_05.png",
            "road_06": "assets/road_06.png",
            "road_07": "assets/road_07.png",
            "road_08": "assets/road_08.png",
            "road_09": "assets/road_09.png",
            "road_10": "assets/road_10.png",
            "road_11": "assets/road_11.png"
        };
        this.tiles = {};
        this.loadedImageCount = 0;
    }

    componentDidMount() {
        this.init()
        this.sensorDetails = [
            {
                "api": "1.0.0",
                "sensor": "1.0.0",
                "upgradeAvailable": true,
                "location": {
                    "past": [0,0],
                    "current": {
                        "x": 0,
                        "y": 0
                    },
                    "future": {
                        "x": 1,
                        "y": 0
                    }
                }
            },
            // {
            //     "api": "1.0.0",
            //     "sensor": "1.0.0",
            //     "upgradeAvailable": true,
            //     "location": [
            //         [2,2],
            //         [2,2],
            //         [2,1]
            //     ],
            // },
            // {
            //     "api": "1.0.0",
            //     "sensor": "1.0.0",
            //     "upgradeAvailable": true,
            //     "x": 0,
            //     "y": 0
            // }
        ]
    }

    // https://stackoverflow.com/questions/14757659/loading-an-image-onto-a-canvas-with-javascript
    // https://stackoverflow.com/questions/17416706/canvas-image-drawing-order
    loadImages() {
        let imageLoadBegin = performance.now();
        for (const [key, value] of Object.entries(this.images)) {
            let image = new Image();
            this.tiles[key] = image;

            image.onload=function(){
                this.loadedImageCount = this.loadedImageCount + 1;

                if (this.loadedImageCount === Object.keys(this.images).length) {
                    let imageLoadEnd = performance.now()
                    console.log(this.loadedImageCount + " Images Loaded. Time Taken: " + (imageLoadEnd - imageLoadBegin) + "ms")
                    this.renderWorld()
                }
            }.bind(this);

            image.src = value
        }
    }

    init() {
        this.loadImages();
    }

    componentDidUpdate(prevProps, prevState, snapshot) {
        this.renderWorld()
    }

    renderWorld() {
        let canvasWidth = 500;
        let canvasHeight = 500;


        let renderBegin = performance.now();

        let l1 = document.getElementById("layer1");

        l1.width = canvasWidth;
        l1.height = canvasHeight;

        let layer1 = l1.getContext("2d");

        layer1.clearRect(0, 0, 500, 500);

        let map = [
            ["road_08","road_04","road_10"],
            ["road_07","road_03","road_05"],
            ["road_09","road_06","road_11"]
        ];

        let xMiddle = canvasWidth / 2;
        let yMiddle = canvasHeight / 2;

        let worldWidth = map[0].length;
        let worldHeight = map.length;

        let xOffset = xMiddle - 64;
        let yOffset = yMiddle - 138;

        for (let x = 0; x < worldHeight; x++) {
            for (let y = 0; y < worldWidth; y++) {
                let tile = map[x][y];

                layer1.drawImage(this.tiles[tile], xOffset - (x * 64) + (y * 64), yOffset + (x * 37) + (y * 37));
            }
        }



        let x = 0;
        let y = 0;

        // currentX = history[t][0];
        // currentY = history[t][1];
        // futureX = history[t + 1][0];
        // futureY = history[t + 1][1];



        let spriteMapAnimation = {
            "0001": "bus_01",
            "0010": "bus_03",
            "1020": "bus_03",
            "1011": "bus_01",
            "1000": "bus_07",
            "2021": "bus_01",
            "2010": "bus_07",
            "0100": "bus_05",
            "0102": "bus_01",
            "0111": "bus_03",
            "0201": "bus_05",
            "0212": "bus_03",
            "1202": "bus_07",
            "1211": "bus_05",
            "1222": "bus_03",
            "2212": "bus_07",
            "2221": "bus_05",
            "2122": "bus_01",
            "2111": "bus_07",
            "2120": "bus_05",
            "1101": "bus_07",
            "1110": "bus_05",
            "1112": "bus_01",
            "1121": "bus_03"
        }

        let spriteMapOffsets = {
            // X: 0, Y: 0
            "0001": [10, 34],
            "0010": [70, 34],
            // X: 1, Y: 0
            "1020": [135, 70],
            "1011": [70, 70],
            "1000": [70, 34],
            // X: 2, Y: 0
            "2021": [135, 106],
            "2010": [135, 70],
            // X: 0, Y: 1
            "0100": [10, 34],
            "0102": [-60, 70],
            "0111": [10, 70],
            // X: 0, Y: 2
            "0201": [-60,70],
            "0212": [-60,106],
            // X: 1, Y: 2
            "1202": [-60,106],
            "1211": [10, 106],
            "1222": [10, 145],
            // X: 2, Y: 2
            "2212": [10, 145],
            "2221": [70, 145],
            // X: 2, Y: 1
            "2122": [70, 145],
            "2111": [70, 106],
            "2120": [135, 106],
            // X: 1, Y: 1
            "1101": [10, 70],
            "1110": [70, 70],
            "1112": [10, 106],
            "1121": [70, 106]
        }

        Object.keys(this.props.sensorData).map((key, index) => {
            let spriteMapKey =
                this.props.sensorData[key][0]["location"]["x"] +
                this.props.sensorData[key][0]["location"]["y"] +
                this.props.sensorData[key][1]["location"]["x"] +
                this.props.sensorData[key][1]["location"]["y"]

            let vehicleXOffset = xOffset + spriteMapOffsets[spriteMapKey][0];
            let vehicleYOffset = yOffset + spriteMapOffsets[spriteMapKey][1];

            layer1.drawImage(this.tiles[spriteMapAnimation[spriteMapKey]], vehicleXOffset + (x * 32) + (y * 32), vehicleYOffset + (x * 18.5) + (y * 18.5), 48, 48);
        })







        let renderEnd = performance.now();

        let timeElapsed = renderEnd - renderBegin;
        // console.log("Render Finished. Time Taken: " + timeElapsed + "ms");
    }

    render() {
        return <World>
            <Layer1 id="layer1"/>
        </World>
    }
}

export default WorldComponent;