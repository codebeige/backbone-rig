'use strict'
require './spec_helper'

Workflow = require '../lib/workflow'

describe 'Rig.Workflow', ->
  context 'constructor', ->
    it 'creates transitions', ->
      workflow = new Workflow transitions: [ name: 'foo', from: 'a', to: 'b' ]
      expect(workflow).to.have.property 'foo'
                              .that.is.a 'function'

    context 'options', ->
      it 'assigns initial step', ->
        workflow = new Workflow initialStep: 'off'
        expect(workflow).to.have.property 'initialStep', 'off'

      it 'assigns transitions', ->
        workflow = new Workflow transitions: [
          name: 'turnOn', from: 'off', to: 'on'
        ]
        expect(workflow).to.have.property 'transitions'
                                .that.eql [
          name: 'turnOn', from: 'off', to: 'on'
        ]

      it 'assigns steps', ->
        workflow = new Workflow steps: 'off': enter: null
        expect(workflow).to.have.property 'steps'
                                .that.eql 'off': enter: null

      it 'assigns initialize method', ->
        initialize = ->
        workflow = new Workflow initialize: initialize
        expect(workflow).to.have.property 'initialize', initialize

    context 'initial state', ->
      it 'sets initial state', ->
        workflow = new Workflow initialStep: 'off'
        expect(workflow).to.have.property 'currentStep', 'off'

      it 'triggers enter callback', ->
        enter = @spy()
        workflow = new Workflow
          initialStep: 'off'
          steps: 'off': enter: enter
        expect(enter).to.have.been.calledOnce

      it 'forwards custom options to enter callback', ->
        enter = @spy()
        workflow = new Workflow
          initialStep: 'off'
          steps: 'off': enter: enter
          foo: 'bar'
        expect(enter).to.have.been.calledWith foo: 'bar'

    context 'initialize', ->
      initialize = null

      beforeEach ->
        initialize = @spy()

      it 'calls initialize method', ->
        workflow = new Workflow initialize: initialize
        expect(initialize).to.have.been.calledOnce

      it 'forwards custom constructor options', ->
        workflow = new Workflow initialize: initialize, foo: 'bar'
        expect(initialize).to.have.been.calledWith foo: 'bar'

      it 'calls initialize method before enter callback', ->
        enter = @spy()
        workflow = new Workflow
          initialStep: 'off'
          initialize: initialize
          steps: 'off', enter: enter
        expect(initialize).to.have.been.calledBefore enter

  context 'instance', ->
    workflow = null

    beforeEach ->
      workflow = new Workflow
      workflow.currentStep = 'off'

    describe '#at()', ->
      it 'returns true when current step', ->
        workflow.currentStep = 'off'
        result = workflow.at 'off'
        expect(result).to.be.true

      it 'returns false when not current step', ->
        workflow.currentStep = 'off'
        result = workflow.at 'on'
        expect(result).to.be.false

    describe '#can()', ->
      it 'returns true when transition can be applied', ->
        workflow.transitions = [name: 'turnOn', from: 'off', to: 'on']
        workflow.currentStep = 'off'
        result = workflow.can 'turnOn'
        expect(result).to.be.true

      it 'returns false when transition cannot be applied', ->
        workflow.transitions = [name: 'turnOn', from: 'off', to: 'on']
        workflow.currentStep = 'on'
        result = workflow.can 'turnOn'
        expect(result).to.be.false

      it 'handles multiple allowed states', ->
        workflow.transitions = [
          name: 'turnOn', from: ['idle', 'off'], to: 'on'
        ]
        workflow.currentStep = 'off'
        result = workflow.can 'turnOn'
        expect(result).to.be.true

      it 'handles multiple transitions of same name', ->
        workflow.transitions = [
          { name: 'turnOn', from: 'off', to: 'idle' }
          { name: 'turnOn', from: 'idle', to: 'on'  }
        ]
        workflow.currentStep = 'idle'
        result = workflow.can 'turnOn'
        expect(result).to.be.true

    describe 'transition', ->
      transition = null

      beforeEach ->
        transition = name: 'turnOn', from: 'off', to: 'on'
        workflow.transitions = [transition]
        workflow.createTransitions()

      it 'changes state', ->
        workflow.currentStep = 'off'
        workflow.turnOn()
        expect(workflow).to.have.property 'currentStep', 'on'

      it 'raises error if not applicable', ->
        workflow.can = -> false
        expect(workflow.turnOn).to.throw Error

      it 'handles multiple from states', ->
        workflow.transitions = [
          name: 'turnOn', from: ['idle', 'off'], to: 'on'
        ]
        workflow.createTransitions()
        workflow.turnOn()
        expect(workflow).to.have.property 'currentStep', 'on'

      it 'handles multiple from states', ->
        workflow.transitions = [
          { name: 'turnOn', from: 'idle', to: 'on'  }
          { name: 'turnOn', from: 'off', to: 'idle' }
        ]
        workflow.createTransitions()
        workflow.currentStep = 'idle'
        workflow.turnOn()
        expect(workflow).to.have.property 'currentStep', 'on'

      context 'callbacks', ->
        callback = null

        beforeEach ->
          callback = @spy()

        callbackExamples = ->
          it 'is triggered', ->
            workflow.turnOn()
            expect(callback).to.have.been.calledOnce

          it 'is called on workflow instance', ->
            workflow.turnOn()
            expect(callback).to.have.been.calledOn workflow

          it 'is called with arguments from transition', ->
            workflow.turnOn fast: yes
            expect(callback).to.have.been.calledWith fast: yes

        context 'exit callback', ->
          beforeEach ->
            workflow.steps = 'off': exit: callback

          callbackExamples()

          it 'handles multiple from states', ->
            workflow.transitions = [
              name: 'turnOn', from: ['idle', 'off'], to: 'on'
            ]
            workflow.createTransitions()
            workflow.turnOn()
            expect(callback).to.have.been.calledOnce

        context 'enter callback', ->
          beforeEach ->
            workflow.steps = 'on': enter: callback

          callbackExamples()

      context 'hooks', ->
        hook = null

        beforeEach ->
          hook = @spy()

        hookExamples = ->
          it 'is triggered once', ->
            workflow.turnOn()
            expect(hook).to.have.been.calledOnce

          it 'passes transition and arguments to callback', ->
            workflow.turnOn foo: 'bar'
            expect(hook).to.have.been.calledWith transition, foo: 'bar'

        context 'transition:before', ->
          beforeEach ->
            workflow.on 'transition:before', hook

          hookExamples()

        context 'transition:before:name', ->
          beforeEach ->
            workflow.on 'transition:before:turnOn', hook

          hookExamples()

        context 'step:exit:name', ->
          beforeEach ->
            workflow.on 'step:exit:off', hook

          hookExamples()

          it 'handles multiple from states', ->
            workflow.transitions = [
              name: 'turnOn', from: ['idle', 'off'], to: 'on'
            ]
            workflow.createTransitions()
            workflow.turnOn()
            expect(hook).to.have.been.calledOnce

        context 'step:exit', ->
          beforeEach ->
            workflow.on 'step:exit', hook

          hookExamples()

        context 'step:enter:name', ->
          beforeEach ->
            workflow.on 'step:enter:on', hook

          hookExamples()

        context 'step:enter', ->
          beforeEach ->
            workflow.on 'step:enter', hook

          hookExamples()

        context 'transition:after:name', ->
          beforeEach ->
            workflow.on 'transition:after:turnOn', hook

          hookExamples()

        context 'transition:after', ->
          beforeEach ->
            workflow.on 'transition:after', hook

          hookExamples()

      context 'order', ->
        calls = null

        logger = (event) ->
          -> calls.push event

        watch = (events...) ->
          _(events).each (event) ->
            workflow.on event, logger(event)

        beforeEach ->
          calls = []
          workflow.steps =
            'off':
              exit: logger 'exit()'
            'on':
              enter: logger 'enter()'

        it 'wraps general transition hooks around callbacks', ->
          watch 'transition:before'
              , 'transition:after'
          workflow.turnOn()
          expect(calls).to.eql [
            'transition:before'
            'exit()'
            'enter()'
            'transition:after'
          ]

        it 'wraps transition specific hooks around callbacks', ->
          watch 'transition:before:turnOn'
              , 'transition:after:turnOn'
          workflow.turnOn()
          expect(calls).to.eql [
            'transition:before:turnOn'
            'exit()'
            'enter()'
            'transition:after:turnOn'
          ]

        it 'triggers general step hooks after callbacks', ->
          watch 'step:exit'
              , 'step:enter'
          workflow.turnOn()
          expect(calls).to.eql [
            'exit()'
            'step:exit'
            'enter()'
            'step:enter'
          ]

        it 'triggers step specific hooks after callbacks', ->
          watch 'step:exit:off'
              , 'step:enter:on'
          workflow.turnOn()
          expect(calls).to.eql [
            'exit()'
            'step:exit:off'
            'enter()'
            'step:enter:on'
          ]
