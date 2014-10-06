'use strict'
require './spec_helper'

Rig = require '../lib/rig'

Application = require '../lib/application'
View        = require '../lib/view'
Router      = require '../lib/router'

describe 'Rig', ->

  it 'provides a reference to the application base class', ->
    expect(Rig).to.have.property 'Application', Application

  it 'provides a reference to the view base class', ->
    expect(Rig).to.have.property 'View', View

  it 'provides a reference to the router base class', ->
    expect(Rig).to.have.property 'Router', Router
