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
