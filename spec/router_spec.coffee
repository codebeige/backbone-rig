'use strict'
require 'spec/support'

Router = require 'lib/router'

describe 'Rig.Router', ->

  router = null

  beforeEach ->
    router = new Router

  it 'is a Backbone router', ->
    expect(router).to.be.an.instanceOf Backbone.Router
