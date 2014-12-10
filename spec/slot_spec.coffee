'use strict'
require './spec_helper'

Slot = require '../lib/slot'

describe 'Rig.Slot', ->
  fakeEl = (tagName = 'div')->
    $("<#{tagName}>")[0]

  fakeView = ->
    new Backbone.View

  context 'constructor', ->
    it 'assigns el from options', ->
      el = fakeEl()
      slot = new Slot el: el
      expect(slot).to.have.property 'el', el

    it 'caches jQuery wrapper', ->
      el = fakeEl()
      slot = new Slot el: el
      expect(slot).to.have.property '$el'
                     .with.deep.property '[0]', el

    context 'creating el', ->
      it 'uses tag name from options', ->
        slot = new Slot tagName: 'ul'
        expect(slot.el).to.have.property 'tagName', 'UL'

      it 'uses default tag name when not present in options', ->
        slot = new Slot tagName: null
        expect(slot.el).to.have.property 'tagName', 'DIV'

      it 'applies class name from options', ->
        slot = new Slot className: 'sidebar'
        expect(slot.$el).to.have.$class 'sidebar'

      it 'applies id from options', ->
        slot = new Slot id: 'sidebar'
        expect(slot.$el).to.have.$attr 'id', 'sidebar'

      it 'applies attributes from options', ->
        slot = new Slot attributes: {'data-id': '1234'}
        expect(slot.$el).to.have.$attr 'data-id', '1234'

  context 'instance', ->
    slot = null

    beforeEach ->
      slot = new Slot

    describe '#$', ->
      it 'selects descendants from el', ->
        h1 = fakeEl 'h1'
        slot.$el.append h1
        descendant = slot.$ 'h1'
        expect(descendant[0]).to.equal h1

    describe '#view', ->
      it 'defaults to null', ->
        expect(slot).to.have.property 'view', null

      it 'keeps reference to currently selected view', ->
        view = fakeView()
        slot.switch view
        expect(slot).to.have.property 'view', view

    describe '#switch()', ->
      view = null

      beforeEach ->
        view = fakeView()

      it 'renders view', ->
        render = @stub(view, 'render').returns view
        slot.switch view
        expect(render).to.have.been.calledOnce

      it 'appends el', ->
        slot.switch view
        expect($.contains slot.el, view.el).to.be.true

      it 'removes most recent view', ->
        slot.view = fakeView()
        remove = @stub slot.view, 'remove'
        slot.switch view
        expect(remove).to.have.been.calledOnce

    describe '#remove()', ->
      it 'removes current view', ->
        slot.view = fakeView()
        remove = @stub slot.view, 'remove'
        slot.remove()
        expect(remove).to.have.been.calledOnce

      it 'removes el', ->
        remove = @stub()
        slot.$el = remove: remove
        slot.remove()
        expect(remove).to.have.been.calledOnce
