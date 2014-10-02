chai       = require 'chai'
sinon      = require 'sinon'
sinonChai  = require 'sinon-chai'
jqueryChai = require 'chai-jq'

jquery     = require 'jquery'
underscore = require 'underscore'
backbone   = require 'backbone'

window.expect = chai.expect
chai.use sinonChai
chai.use jqueryChai

window._ = underscore

jquery.fx.off = yes
window.$ = window.jQuery = jquery


window.Backbone = backbone
Backbone.$ = jquery

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
