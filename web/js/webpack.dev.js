const path = require('path');
const merge = require('webpack-merge');
const common = require('./webpack.common.js');

module.exports = merge(common, {
  mode: 'development',
  devtool: 'inline-source-map',
  devServer: {
    contentBase: path.join(__dirname, 'public/'),
    port: 9000,
    historyApiFallback: true,
    proxy: {
      '/api': {
        target: 'http://34.74.114.194/api',
        pathRewrite: {'^/api': ''},
        secure: false,
        changeOrigin: true
      }
    }
  },
});
