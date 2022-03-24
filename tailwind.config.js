
const path = require('path')
const glob = require('glob')
const MiniCssExtractPlugin = require('mini-css-extract-plugin')
const PurgecssPlugin = require('purgecss-webpack-plugin')

const PATHS = {
  src: path.join(__dirname, '_site')
}

class TailwindExtractor {
  static extract(content) {
    return content.match(/[A-z0-9-:\/]+/g);
  }
}

module.exports = {
  entry: {
    'bundle.min.css': [
      path.resolve(__dirname, 'assets/css/main.css'),
      path.resolve(__dirname, 'assets/css/mobile.css'),
      path.resolve(__dirname, 'assets/css/vendor/semantic.min.css'),
      path.resolve(__dirname, 'assets/css/vendor/syntax.css')
    ],
    'bundle.js': [
      path.resolve(__dirname, 'src/index.js')
    ]
  },
  output: {
    filename: '[name]',
    path: path.join(__dirname, 'dist')
  },
  optimization: {
    splitChunks: {
      cacheGroups: {
        styles: {
          name: 'styles',
          test: /\.css$/,
          chunks: 'all',
          enforce: true
        }
      }
    }
  },
  module: {
    rules: [
      {
        test: /\.css$/,
        use: [
          MiniCssExtractPlugin.loader,
          "css-loader"
        ]
      }
    ]
  },
  plugins: [
    new MiniCssExtractPlugin({
      filename: "[name].css",
    }),
    // new PurgecssPlugin({
    //   paths: glob.sync(`${PATHS.src}/**/*`,  { nodir: true }),
    // }),
  ]
}
