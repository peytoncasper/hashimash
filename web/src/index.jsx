import * as React from 'react'
import ReactDOM from 'react-dom';

class RootComponent extends React.Component {
  render() {
    return <h1>Hello World</h1>;
  }
}

ReactDOM.render(
  <RootComponent/>,
  document.getElementById('root')
);