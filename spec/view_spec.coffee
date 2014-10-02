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

    describe '#render()', ->

      template = null

      beforeEach ->
        template = @stub()
        view.template = template

      content = (view) ->
        view.$el.html()

      it 'can be chained', ->
        result = view.render()
        expect(result).to.equal view

      it 'updates content from template', ->
        view.$el.html 'I feel deprecated.'
        template.returns 'YES, you are rigged!'
        view.render()
        expect(content view).to.equal 'YES, you are rigged!'

      it 'passes data to template', ->
        view.data = -> foo: 'bar'
        view.render()
        expect(template).to.have.been.calledWith foo: 'bar'
