'use strict'
require './spec_helper'

Rig = require '../lib'

Application = require '../lib/application'
View        = require '../lib/view'
Workflow    = require '../lib/workflow'

describe 'Rig', ->

  it 'provides a reference to the application base class', ->
    expect(Rig).to.have.property 'Application', Application

  it 'provides a reference to the view base class', ->
    expect(Rig).to.have.property 'View', View

  it 'provides a reference to the workflow base class', ->
    expect(Rig).to.have.property 'Workflow', Workflow
