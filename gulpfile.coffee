'use strict'

gulp       = require 'gulp'
gutil      = require 'gulp-util'
del        = require 'del'
browserify = require 'browserify'
src        = require 'vinyl-source-stream'
streamify  = require 'gulp-streamify'
uglify     = require 'gulp-uglify'
rename     = require 'gulp-rename'
size       = require 'gulp-size'

gulp.task 'clean', (done) ->
  del ['build'], done

gulp.task 'clobber', ['clean'], (done) ->
  del ['node_modules/*', '!node_modules/lib', '!node_modules/test'], done

gulp.task 'build', ->
  browserify
    entries: ['./lib/rig.coffee']
    extensions: ['.coffee']
  .bundle
    standalone: 'Rig'
  .on('error', gutil.log)

  .pipe(src 'backbone-rig.js')
  .pipe(gulp.dest 'build')

  .pipe(streamify uglify())
  .pipe(rename suffix: '.min')
  .pipe(gulp.dest 'build')
  .pipe(streamify size())
