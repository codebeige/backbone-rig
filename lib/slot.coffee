'use strict'

createWrapper = (options) ->
  if options.el?
    Backbone.$ options.el
  else
    options.tagName ?= 'div'
    options.attributes ?= {}
    options.attributes.id = options.id if options.id?

    Backbone.$ "<#{options.tagName}>"
      .addClass options.className
      .attr options.attributes

class Slot
  view: null

  constructor: (options = {}) ->
    @$el = createWrapper options
    @el  = @$el[0]

  $: (selector) ->
    @$el.find selector

  switch: (view) ->
    @clear()
    @view = view.render()
    @$el.append @view.el

  clear: ->
    @view.remove() if @view?

  remove: ->
    @clear()
    @$el.remove()

module.exports = Slot
