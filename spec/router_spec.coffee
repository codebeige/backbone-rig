'use strict'
require './spec_helper'

Router = require '../lib/router'

describe 'Rig.Router', ->

  router = null

  beforeEach ->
    router = new Router

  it 'is a Backbone router', ->
    expect(router).to.be.an.instanceOf Backbone.Router
