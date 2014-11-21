'use strict'

module.exports = class Workflow
  _(@::).extend Backbone.Events

  currentStep: null

  constructor: ({@initialStep, @transitions, @steps} = {}) ->

  createTransitions: ->
    _(@transitions).each (t) =>
      @[t.name] = (args...) ->
        @steps?[t.from]?.exit?.apply @, args
        @currentStep = t.to
        @steps?[t.to]?.enter?.apply @, args
