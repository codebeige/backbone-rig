'use strict'

class View extends Backbone.View

  initialize: (options = {}) ->
    _(@).extend _(options).pick 'template', 'data'

  template: ->
    ''

  data: ->
    {}

  render: ->
    @$el.html @template @data()
    @

module.exports = View
