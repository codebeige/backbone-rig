'use strict'

var gulp    = require('gulp')
  , gutil   = require('gulp-util')
  , coffee  = require('gulp-coffee')
  , del     = require('del')

var SOURCE = 'src/**/*.coffee'

gulp.task('clean', function (done) {
  del(['build', 'tmp'], done)
})

gulp.task('clobber', ['clean'], function (done) {
  del(['node_modules'], done)
})

gulp.task('compile', function () {
  var dest = 'build/development'
  return gulp.src(SOURCE)
    .pipe(coffee())
    .on('error', gutil.log)
    .pipe(gulp.dest(dest))
})

gulp.task('default', ['compile'])
