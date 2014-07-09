'use strict'

var gulp       = require('gulp')
  , gutil      = require('gulp-util')
  , del        = require('del')
  , browserify = require('browserify')
  , src        = require('vinyl-source-stream')
  , streamify  = require('gulp-streamify')
  , uglify     = require('gulp-uglify')
  , rename     = require('gulp-rename')
  , size       = require('gulp-size')

gulp.task('clean', function (done) {
  del(['build'], done)
})

gulp.task('clobber', ['clean'], function (done) {
  del(['node_modules'], done)
})

gulp.task('build', function () {
  browserify(
    { entries: ['./src/rig.coffee']
    , extensions: ['.coffee']
    }
  )
  .bundle()
  .pipe(src('backbone-rig.js'))
  .pipe(gulp.dest('build'))
  .pipe(streamify(uglify()))
  .pipe(rename({suffix: '.min'}))
  .pipe(gulp.dest('build'))
  .pipe(streamify(size()))
  .on('error', gutil.log)
})
