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
  constructor: (options = {}) ->
    @$el = createWrapper options
    @el  = @$el[0]

  $: (selector) ->
    @$el.find selector

module.exports = Slot
