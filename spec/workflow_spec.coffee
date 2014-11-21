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

    context 'initialize', ->
      initialize = null

      beforeEach ->
        initialize = @spy()

      it 'calls initialize method', ->
        workflow = new Workflow initialize: initialize
        expect(initialize).to.have.been.calledOnce

      it 'forwards constructor options', ->
        workflow = new Workflow initialize: initialize
        expect(initialize).to.have.been.calledWith initialize: initialize

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
