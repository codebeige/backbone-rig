'use strict'

lift = (initializer) ->
  initialize: if _.isFunction initializer.initialize
                  _(initializer.initialize).bind initializer
              else
                ->

  start:      if _.isFunction initializer.start
                _(initializer.start).bind initializer
              else if _.isFunction initializer
                _(initializer).bind undefined
              else
                ->

class Application

  _(@::).extend Backbone.Events

  config: null

  constructor: (@config = {}) ->
    @_inits = []
    @_start = $.Deferred()

  register: (initializer) ->
    initializer = lift initializer
    @_inits.push initializer.initialize @config, @
    @_start.then initializer.start
    @

  start: (config) ->
    $.extend true, @config, config
    $.when @_inits...
      .then => @_start.resolve @config, @
    @

module.exports = Application
