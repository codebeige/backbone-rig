'use strict'

list = (value) ->
  if _.isArray(value) then value else [ value ]

class View extends Backbone.View

  layout: ->
    false

  content: ->
    @$el

  template: ->
    ''

  data: ->
    {}

  initialize: (options = {}) ->
    _(@).extend _(options).pick 'template', 'data'

  setElement: (el, delegate, layout) ->
    super el, delegate
    @renderLayout() unless layout is false
    @

  renderLayout: ->
    @$el.html layout if layout = @layout()

  render: ->
    data   = @data()
    chunks = _(list data).map @template
    $els   = $ @content()
    if $els.length is 1
      $els.html chunks.join "\n"
    else
      $els.html (i) -> chunks[i]
    @update data
    @

  update: (data) ->

module.exports = View
