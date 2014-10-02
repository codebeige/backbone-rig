'use strict'

list = (value) ->
  if _.isArray(value) then value else [ value ]

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
    data   = list @data()
    chunks = _(data).map @template
    $els   = $ @content()
    if $els.length is 1
      $els.html chunks.join "\n"
    else
      $els.html (i) -> chunks[i]
    @

module.exports = View
