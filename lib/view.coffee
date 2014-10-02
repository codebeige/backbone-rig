'use strict'

class View extends Backbone.View

  markup: ->
    ''

  content: ->
    @$el

  template: ->
    ''

  data: ->
    {}

  initialize: (options = {}) ->
    _(@).extend _(options).pick 'template', 'data'

  setElement: (el, delegate) ->
    super
    @$el.html @markup()
    @

  render: ->
    @content().html @template @data()
    @

module.exports = View
