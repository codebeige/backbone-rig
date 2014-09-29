'use strict'
require 'test/support'

describe 'Router', ->

  it 'is a Backbone router', ->
    expect(router).to.be.an.instanceOf Backbone.Router
