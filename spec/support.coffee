chai      = require 'chai'
sinon     = require 'sinon'
sinonChai = require 'sinon-chai'

jquery     = require 'jquery'
underscore = require 'underscore'
backbone   = require 'backbone'

window.expect = chai.expect
chai.use sinonChai

do ->

  sandbox = null

  beforeEach ->
    sandbox = sinon.sandbox.create
      injectInto: @
      properties: ['spy', 'stub', 'mock', 'clock', 'server', 'requests']
      useFakeTimers: on
      useFakeServer: on

  afterEach ->
    sandbox.restore()

jquery.fx.off = yes
window.$ = window.jQuery = jquery

window._ = underscore

window.Backbone = backbone
