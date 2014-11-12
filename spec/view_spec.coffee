'use strict'
require './spec_helper'

View = require '../lib/view'

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

      it 'calls update after content was rendered', ->
        view.template = -> '<p>before</p>'
        view.update = -> @$('p').html 'after'
        view.render()
        expect(view.$el).to.have.$html '<p>after</p>'

      it 'passes data to update call', ->
        update = @spy()
        view.update = update
        view.data = -> foo: 'bar'
        view.render()
        expect(update).to.have.been.calledWith foo: 'bar'

      context 'updates on multiple items', ->

        it 'renders template for every item in data', ->
          view.data = -> [{title: 'Do this'}, {title: 'And do that'}]
          template.withArgs(title: 'Do this'    ).returns '<li>Do this</li>'
          template.withArgs(title: 'And do that').returns '<li>And do that</li>'
          view.render()
          expect(view.$el).to.contain.$html '<li>Do this</li>'
                      .and.to.contain.$html '<li>And do that</li>'

        it 'updates each content element respectively', ->
          view.data = -> [{header: 'Tasks'}, {title: 'Do this'}]
          template.withArgs(header: 'Tasks'     ).returns 'Tasks'
          template.withArgs(title: 'Do this').returns '<li>Do this</li>'
          view.$el.html '<h3></h3><ul></ul>'
          view.content = -> @$ 'h3,ul'
          view.render()
          expect(view.$el).to.contain.$html '<h3>Tasks</h3>'
                      .and.to.contain.$html '<ul><li>Do this</li></ul>'

        it 'calls update only once', ->
          update = @spy()
          view.update = update
          view.render()
          expect(update).to.have.been.calledOnce
