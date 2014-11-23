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

findTransition = (transitions, name, from) ->
  _(transitions).find (transition) ->
    transition.name is name and from in [].concat(transition.from)

errorMessage = (name, step) ->
  "Transition '#{name}' not allowed from '#{step}'"

transition = (t, args...) ->
  trigger = _(triggerEvents).partial @, _, _, t, args...
  trigger 'transition:before', t.name
  step(@steps, @currentStep).exit.apply @, args
  trigger 'step:exit', @currentStep
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
    _.chain(@transitions)
      .pluck 'name'
      .uniq()
      .each (name) =>
        @[name] = (args...) ->
          unless t = findTransition @transitions, name, @currentStep
            throw new Error(errorMessage name, @currentStep)
          transition.call @, t, args...

  at: (step) ->
    @currentStep is step

  can: (transition) ->
    findTransition(@transitions, transition, @currentStep)?

module.exports = Workflow
