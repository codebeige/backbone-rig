'use strict'
require 'spec/support'

View = require 'lib/view'

describe 'Rig.View', ->

  context 'constructor', ->

    it 'assigns template from options', ->
      template = -> '<p>Hi!</p>'
      view = new View template: template
      expect(view.template).to.equal template

    it 'assigns serializer from options', ->
      data = -> bar: 'baz'
      view = new View data: data
      expect(view.data).to.equal data

  context 'instance', ->

    view = null

    beforeEach ->
      view = new View

    it 'is a Backbone view', ->
      expect(view).to.be.an.instanceOf Backbone.View

    describe '#setElement()', ->

      el = null

      createEl = ->
        $('<div>')[0]

      beforeEach ->
        el = createEl()

      it 'can be chained', ->
        result = view.setElement el
        expect(result).to.equal view

      it 'calls super implementation', ->
        original = @spy Backbone.View::, 'setElement'
        view.setElement el, false
        expect(original).to.have.been.calledOnce
        expect(original).to.have.been.calledWith el, false

      it 'creates markup inside el', ->
        view.markup = -> '<ul></ul>'
        view.setElement view.el
        expect(view.$el).to.have.$html '<ul></ul>'

    describe '#render()', ->

      template = null

      beforeEach ->
        template = @stub()
        view.template = template

      it 'can be chained', ->
        result = view.render()
        expect(result).to.equal view

      it 'updates content from template', ->
        view.$el.html 'I feel deprecated.'
        template.returns 'YES, you are rigged!'
        view.render()
        expect(view.$el).to.have.$html 'YES, you are rigged!'

      it 'passes data to template', ->
        view.data = -> foo: 'bar'
        view.render()
        expect(template).to.have.been.calledWith foo: 'bar'

      it 'updates provided content element', ->
        ul = $ '<ul>'
        view.content = -> ul
        template.returns '<li>Do something</li>'
        view.render()
        expect(ul).to.have.$html '<li>Do something</li>'
