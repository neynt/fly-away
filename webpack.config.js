var path = require('path');
var webpack = require('webpack');

var debug = process.env.NODE_ENV !== 'production';

function resolve(dir) {
  return path.join(__dirname, dir);
}

module.exports = {
  entry: {
    app: './src/index.ls',
  },
  output: {
    path: resolve('./build'),
    filename: 'bundle.js',
  },
  resolve: {
    extensions: ['.ls'],
    alias: {
      '@': resolve('src'),
    },
  },
  module: {
    rules: [
      {
        test: /\.ls$/,
        loader: 'livescript-loader',
      },
    ],
  },
};
