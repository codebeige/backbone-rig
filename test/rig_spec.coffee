require 'test/support'
rig = require 'lib/rig'

describe 'Rig', ->

  it 'exists', ->
    expect(rig).to.have.property 'Router'
