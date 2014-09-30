require 'spec/support'

Rig = require 'lib/rig'

Application = require 'lib/application'
Router      = require 'lib/router'

describe 'Rig', ->

  it 'provides a reference to the application bas class', ->
    expect(Rig).to.have.property 'Application', Application

  it 'provides a reference to the router base class', ->
    expect(Rig).to.have.property 'Router', Router
