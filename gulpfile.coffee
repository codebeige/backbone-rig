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
  del ['node_modules'], done

gulp.task 'build', ->
  browserify
    entries: ['./lib/index.coffee']
    extensions: ['.coffee']
    standalone: 'Rig'
  .bundle()
  .on 'error', gutil.log

  .pipe src 'backbone-rig.js'
  .pipe gulp.dest 'build'

  .pipe streamify uglify()
  .pipe rename suffix: '.min'
  .pipe gulp.dest 'build'
  .pipe streamify size()

gulp.task 'default', ['build']
