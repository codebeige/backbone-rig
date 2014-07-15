require 'test/support'
rig = require 'lib/rig'
router = require 'lib/routes/router.coffee'

describe 'Rig', ->

  it 'provides a reference to the router base class', ->
    expect(rig).to.have.property 'Router', router
