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

    describe 'transitions', ->

      beforeEach ->
        workflow.transitions = [ name: 'turnOn', from: 'off', to: 'on' ]
        workflow.createTransitions()

      it 'changes state', ->
        workflow.currentStep = 'off'
        workflow.turnOn()
        expect(workflow).to.have.property 'currentStep', 'on'

      context 'exit callback', ->

        exit = null

        beforeEach ->
          exit = @spy()
          workflow.steps = 'off': exit: exit

        it 'is triggered', ->
          workflow.turnOn()
          expect(exit).to.have.been.calledOnce

        it 'is called on workflow instance', ->
          workflow.turnOn()
          expect(exit).to.have.been.calledOn workflow

        it 'is called with arguments from transition', ->
          workflow.turnOn fast: yes
          expect(exit).to.have.been.calledWith fast: yes

      context 'enter callback', ->

        enter = null

        beforeEach ->
          enter = @spy()
          workflow.steps = 'on': enter: enter

        it 'is triggered', ->
          workflow.turnOn()
          expect(enter).to.have.been.calledOnce

        it 'is called on workflow instance', ->
          workflow.turnOn()
          expect(enter).to.have.been.calledOn workflow

        it 'is called with arguments from transition', ->
          workflow.turnOn fast: yes
          expect(enter).to.have.been.calledWith fast: yes

    describe 'events', ->

      callback = null

      beforeEach ->
        callback = @spy()

      it 'can broadcast events', ->
        workflow.on 'bingo', callback
        workflow.trigger 'bingo'
        expect(callback).to.have.been.calledOnce

      context 'transition', ->

        transition = null

        beforeEach ->
          transition = name: 'turnOn', from: 'off', to: 'on'
          workflow.transitions = [transition]
          workflow.createTransitions()

        context 'transition:before:name', ->

          beforeEach ->
            workflow.on 'transition:before:turnOn', callback

          it 'is triggered once', ->
            workflow.turnOn()
            expect(callback).to.have.been.calledOnce

          it 'passes transition and arguments to callback', ->
            workflow.turnOn foo: 'bar'
            expect(callback).to.have.been.calledWith transition, foo: 'bar'

          it 'is triggered before general event', ->
            general = @spy()
            workflow.on 'transition:before:turnOn', general
            workflow.turnOn()
            expect(callback).to.have.been.calledBefore general

        context 'transition:before', ->

          beforeEach ->
            workflow.on 'transition:before', callback

          it 'is triggered once', ->
            workflow.turnOn()
            expect(callback).to.have.been.calledOnce

          it 'passes transition and arguments to callback', ->
            workflow.turnOn foo: 'bar'
            expect(callback).to.have.been.calledWith transition, foo: 'bar'

          it 'is triggered before exit callback', ->
            exit = @spy()
            workflow.steps = 'off': exit: exit
            workflow.turnOn()
            expect(callback).to.have.been.calledBefore exit


        context 'step:exit:name', ->

          beforeEach ->
            workflow.on 'step:exit:off', callback

          it 'is triggered once', ->
            workflow.turnOn()
            expect(callback).to.have.been.calledOnce

          it 'passes transition and arguments to callback', ->
            workflow.turnOn foo: 'bar'
            expect(callback).to.have.been.calledWith transition, foo: 'bar'

          it 'is triggered after exit callback', ->
            exit = @spy()
            workflow.steps = 'off': exit: exit
            workflow.turnOn()
            expect(callback).to.have.been.calledAfter exit

        context 'step:exit', ->

          beforeEach ->
            workflow.on 'step:exit', callback

          it 'is triggered once', ->
            workflow.turnOn()
            expect(callback).to.have.been.calledOnce

          it 'passes transition and arguments to callback', ->
            workflow.turnOn foo: 'bar'
            expect(callback).to.have.been.calledWith transition, foo: 'bar'

          it 'is triggered after specific event', ->
            specific = @spy()
            workflow.on 'step:exit:off', specific
            workflow.turnOn()
            expect(callback).to.have.been.calledAfter specific

        context 'step:enter:name', ->

          beforeEach ->
            workflow.on 'step:enter:on', callback

          it 'is triggered once', ->
            workflow.turnOn()
            expect(callback).to.have.been.calledOnce

          it 'passes transition and arguments to callback', ->
            workflow.turnOn foo: 'bar'
            expect(callback).to.have.been.calledWith transition, foo: 'bar'

          it 'is triggered after enter callback', ->
            enter = @spy()
            workflow.steps = 'on': enter: enter
            workflow.turnOn()
            expect(callback).to.have.been.calledAfter enter

        context 'step:enter', ->

          beforeEach ->
            workflow.on 'step:enter', callback

          it 'is triggered once', ->
            workflow.turnOn()
            expect(callback).to.have.been.calledOnce

          it 'passes transition and arguments to callback', ->
            workflow.turnOn foo: 'bar'
            expect(callback).to.have.been.calledWith transition, foo: 'bar'

          it 'is triggered after specific callback', ->
            specific = @spy()
            workflow.on 'step:enter:on', specific
            workflow.turnOn()
            expect(callback).to.have.been.calledAfter specific

        context 'transition:after:name', ->

          beforeEach ->
            workflow.on 'transition:after:turnOn', callback

          it 'is triggered once', ->
            workflow.turnOn()
            expect(callback).to.have.been.calledOnce

          it 'passes transition and arguments to callback', ->
            workflow.turnOn foo: 'bar'
            expect(callback).to.have.been.calledWith transition, foo: 'bar'

          it 'is triggered after step events', ->
            enter = @spy()
            workflow.on 'step:enter', enter
            workflow.turnOn()
            expect(callback).to.have.been.calledAfter enter

        context 'transition:after', ->

          beforeEach ->
            workflow.on 'transition:after', callback

          it 'is triggered once', ->
            workflow.turnOn()
            expect(callback).to.have.been.calledOnce

          it 'passes transition and arguments to callback', ->
            workflow.turnOn foo: 'bar'
            expect(callback).to.have.been.calledWith transition, foo: 'bar'

          it 'is triggered after specific event', ->
            specific = @spy()
            workflow.on 'transition:after:turnOn', specific
            workflow.turnOn()
            expect(callback).to.have.been.calledAfter specific


