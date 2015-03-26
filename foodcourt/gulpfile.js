'use strict';

var gulp = require('gulp'),
  connect = require('gulp-connect'),
  webpack = require('gulp-webpack'),
  jade = require('gulp-jade'),
  less = require('gulp-less');

gulp.task('connect', function () {
  connect.server({
    root: 'build',
    port: 8080,
    livereload: true
  });
});

gulp.task('webpack', function () {
  gulp.src('./foodcourt.js')
    .pipe(webpack({
      module: {
        loaders: [
          { test: /\.js$/, exclude: /node_modules/, loader: 'babel-loader'}
        ]
      },
      output: {
        filename: 'foodcourt.js'
      }
    }))
    .on('error', function (err) {
      console.log(err.toString());
      this.emit('end');
    })
    .pipe(gulp.dest('build/'))
    .pipe(connect.reload());
});

gulp.task('jade', function () {
  gulp.src('index.jade')
    .pipe(jade())
    .pipe(gulp.dest('build'))
    .pipe(connect.reload());
});

gulp.task('less', function () {
  gulp.src('index.less')
    .pipe(less())
    .pipe(gulp.dest('build'))
    .pipe(connect.reload());
});

gulp.task('default', ['webpack', 'jade', 'less']);

gulp.task('watch', ['default', 'connect'], function() {
  gulp.watch('foodcourt.js', ['webpack']);
  gulp.watch('index.jade', ['jade']);
  gulp.watch('index.less', ['less']);
});
