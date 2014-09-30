'use strict'

lift = (initializer) ->
  start: if _.isFunction initializer.start
           _(initializer.start).bind initializer
         else
           _(initializer).bind undefined

class Application

  config: null

  constructor: (@config = {}) ->
    @_init = $.Deferred()

  register: (initializer) ->
    initializer = lift initializer
    @_init.then initializer.start
    @

  start: (config) ->
    $.extend true, @config, config
    @_init.resolve @config, @
    @

module.exports = Application
