'use strict'

CONFIG_OPTIONS = [
  'initialStep'
  'transitions'
  'steps'
  'initialize'
]

config = (options) ->
  _(options).pick CONFIG_OPTIONS...

custom = (options) ->
  _(options).omit CONFIG_OPTIONS...

step = (steps = {}, name) ->
  _(steps[name] || {}).defaults
    enter: ->
    exit: ->

triggerEvents = (hub, type, name, args...) ->
  hub.trigger "#{type}:#{name}", args...
  hub.trigger type, args...

transition = (t, args...) ->
  trigger = _(triggerEvents).partial @, _, _, t, args...
  trigger 'transition:before', t.name
  step(@steps, t.from).exit.apply @, args
  trigger 'step:exit', t.from
  @currentStep = t.to
  step(@steps, t.to).enter.apply @, args
  trigger 'step:enter', t.to
  trigger 'transition:after', t.name

class Workflow
  _(@::).extend Backbone.Events

  initialStep: null

  currentStep: null

  transitions: null

  steps: null

  initialize: ->

  constructor: (options) ->
    _(@).extend config(options)
    opts = custom(options)
    @currentStep = @initialStep
    @initialize opts
    step(@steps, @currentStep).enter.call @, opts

  createTransitions: ->
    _(@transitions).each (t) =>
      @[t.name] = _(transition).bind @, t

module.exports = Workflow
