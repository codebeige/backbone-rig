'use strict'
require './spec_helper'

Workflow = require '../lib/workflow'

describe 'Rig.Workflow', ->
  context 'constructor', ->
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

        beforeEach ->
          calls = []
          workflow.steps =
            'off':
              exit: -> calls.push 'exit()'
            'on':
              enter: -> calls.push 'enter()'
          workflow.on 'all', (event) -> calls.push event

        it 'calls hooks and callbacks in a specific order', ->
          workflow.turnOn()
          expect(calls).to.eql [
            'transition:before'
            'transition:before:turnOn'
            'exit()'
            'step:exit:off'
            'step:exit'
            'enter()'
            'step:enter:on'
            'step:enter'
            'transition:after:turnOn'
            'transition:after'
          ]
