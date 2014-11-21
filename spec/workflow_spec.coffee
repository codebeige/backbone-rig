'use strict'
require './spec_helper'

Workflow = require '../lib/workflow'

describe 'Rig.Workflow', ->

  context 'instance', ->
    workflow = null

    beforeEach ->
      workflow = new Workflow

    describe 'events', ->

      callback = null

      beforeEach ->
        callback = @spy()

      it 'can broadcast events', ->
        workflow.on 'bingo', callback
        workflow.trigger 'bingo'
        expect(callback).to.have.been.calledOnce
