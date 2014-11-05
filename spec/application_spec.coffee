'use strict'
require './spec_helper'

Application = require '../lib/application'

describe 'Rig.Application', ->

  application = null

  context 'constructor', ->

    it 'takes config options', ->
      application = new Application apiRoot: 'https://my.api/root'
      expect(application.config).to.eql apiRoot: 'https://my.api/root'

  context 'instance', ->

    beforeEach ->
      application = new Application

    describe '#register()', ->

      initializer = null

      beforeEach ->
        initializer = @spy()

      it 'can be chained', ->
        result = application.register ->
        expect(result).to.equal application

      it 'defers call', ->
        application.register initializer
        expect(initializer).to.not.have.been.called

      it 'does not defer calls when app is already running', ->
        application.start()
        application.register initializer
        expect(initializer).to.have.been.calledOnce

      it 'calls initializer with no context', ->
        application.register initializer
        application.start()
        expect(initializer).to.have.been.calledOn undefined

      context 'passing an initializer object', ->

        initObject = null

        beforeEach ->
          initObject =
            start: initializer

        it 'uses start method for initialization', ->
          application.register initObject
          application.start()
          expect(initializer).to.have.been.calledOnce

        it 'calls start method on initializer object', ->
          application.register initObject
          application.start()
          expect(initializer).to.have.been.calledOn initObject

      context 'passing an async initializer object', ->

        initObject = null

        beforeEach ->
          initObject =
            initialize: initializer

        it 'immediately calls initialize method', ->
          application.register initObject
          expect(initializer).to.have.been.calledOnce

        it 'passes config and app to initialize method', ->
          application.config = foo: 'bar'
          application.register initObject
          expect(initializer).to.have.been.calledWith foo: 'bar', application

        it 'calls initialize method on initializer object', ->
          application.register initObject
          expect(initializer).to.have.been.calledOn initObject

    describe '#start()', ->

      it 'can be chained', ->
        result = application.start()
        expect(result).to.equal application

      it 'merges passed in config options', ->
        application.config = widget: {width: 200}
        application.start widget: {height: 100}
        expect(application.config).to.eql widget: {width: 200, height: 100}

      context 'when an initializer was registered', ->

        initializer = null

        beforeEach ->
          initializer = @spy()
          application.register initializer

        it 'calls initializers', ->
          application.start()
          expect(initializer).to.have.been.calledOnce

        it 'calls initializers passing config and app', ->
          application.start foo: 'bar'
          expect(initializer).to.have.been.calledWith foo: 'bar', application

      context 'when an async initializer object is registered', ->

        deferred = null
        initializer = null

        beforeEach ->
          deferred = $.Deferred()
          initializer = @spy()

          initObject =
            initialize: -> deferred.promise()

          application.register initObject
          application.register initializer

        it 'defers call of initialzers', ->
          application.start()
          expect(initializer).to.not.have.been.called

        it 'leverages configured defer machanism', ->
          Application.when = -> then: (resolve) -> resolve()
          application.start()
          expect(initializer).to.have.been.calledOnce

    describe 'events', ->

      callback = null

      beforeEach ->
        callback = @spy()

      it 'can broadcast events', ->
        application.on 'bingo', callback
        application.trigger 'bingo'
        expect(callback).to.have.been.calledOnce
