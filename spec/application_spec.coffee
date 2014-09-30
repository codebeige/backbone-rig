'use strict'
require 'spec/support'

Application = require 'lib/application'

describe 'Rig.Application', ->

  application = null

  context 'constructor', ->

    it 'takes config options', ->
      application = new Application apiRoot: 'https://my.api/root'
      expect(application.config).to.eql apiRoot: 'https://my.api/root'

  context 'instance', ->

    beforeEach ->
      application = new Application

    describe '#start()', ->

      it 'merges passed in config options', ->
        application.config = widget: {width: 200}
        application.start widget: {height: 100}
        expect(application.config).to.eql widget: {width: 200, height: 100}

      it 'can be chained', ->
        result = application.start()
        expect(result).to.equal application

    describe '#register()', ->

      initializer = null

      beforeEach ->
        initializer = @spy()

      it 'defers call of initializer', ->
        application.register initializer
        expect(initializer).to.not.have.been.called

      it 'immediately calls initializer when app was already started', ->
        application.start()
        application.register initializer
        expect(initializer).to.have.been.calledOnce

      it 'passes config and app to initializer', ->
        application.register initializer
        application.start foo: 'bar'
        expect(initializer).to.have.been.calledWith foo: 'bar', application

      it 'can be chained', ->
        result = application.register initializer
        expect(result).to.equal application

      it 'allows the initializer to be an object that has a start method', ->
        application.register start: initializer
        application.start()
        expect(initializer).to.have.been.calledOnce

      it 'calls start method on initializer object', ->
        initObject = start: initializer
        application.register initObject
        application.start()
        expect(initializer).to.have.been.calledOn initObject

      it 'calls bare initializer function without context', ->
        application.register initializer
        application.start()
        expect(initializer).to.have.been.calledOn undefined
