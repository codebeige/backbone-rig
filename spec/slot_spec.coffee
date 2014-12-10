'use strict'
require './spec_helper'

Slot = require '../lib/slot'

describe 'Rig.Slot', ->
  fakeEl = (tagName = 'div')->
    $("<#{tagName}>")[0]

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
