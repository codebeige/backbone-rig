'use strict'

module.exports = class Workflow
  _(@::).extend Backbone.Events

  initialStep: null

  currentStep: null

  transitions: null

  steps: null

  initialize: ->

  constructor: (options) ->
    _(@).extend _(options).pick 'initialStep'
                              , 'transitions'
                              , 'steps'
                              , 'initialize'
    @steps ?= {}
    @currentStep = @initialStep
    @initialize options
    @steps[@currentStep]?.enter?()

  createTransitions: ->
    _(@transitions).each (t) =>
      @[t.name] = (args...) ->
        @steps[t.from]?.exit?.apply @, args
        @currentStep = t.to
        @steps[t.to]?.enter?.apply @, args
