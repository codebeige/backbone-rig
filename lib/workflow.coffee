'use strict'

module.exports = class Workflow
  _(@::).extend Backbone.Events

  createTransitions: ->
    _(@transitions).each (t) =>
      @[t.name] = (args...)->
        @steps[t.from]?.exit?.apply @, args
        @steps[t.to]?.enter?.apply @, args
