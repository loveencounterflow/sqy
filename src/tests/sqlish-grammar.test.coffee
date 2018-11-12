

###

parser = new NEARLEY.Parser NEARLEY.Grammar.fromCompiled G
debug join ( key for key of parser ), ' '
debug parser.options
# parser.rewind() is deprecated https://github.com/kach/nearley/issues/261

###



'use strict'


############################################################################################################
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'XXX/TESTS'
log                       = CND.get_logger 'plain',     badge
info                      = CND.get_logger 'info',      badge
whisper                   = CND.get_logger 'whisper',   badge
alert                     = CND.get_logger 'alert',     badge
debug                     = CND.get_logger 'debug',     badge
warn                      = CND.get_logger 'warn',      badge
help                      = CND.get_logger 'help',      badge
urge                      = CND.get_logger 'urge',      badge
echo                      = CND.echo.bind CND
#...........................................................................................................
test                      = require 'guy-test'
eq                        = CND.equals
jr                        = JSON.stringify
#...........................................................................................................
G                         = require '../sqlish-grammar'
NEARLEY                   = require 'nearley'
join                      = ( x, joiner = '' ) -> x.join joiner

#-----------------------------------------------------------------------------------------------------------
@_prune = ->
  for name, value of @
    continue if name.startsWith '_'
    delete @[ name ] unless name in include
  return null

#-----------------------------------------------------------------------------------------------------------
@_main = ->
  test @, 'timeout': 30000

#-----------------------------------------------------------------------------------------------------------
@[ "basic" ] = ( T, done ) ->
  probes_and_matchers = [
    # ["create layout #mylayout;"]
    ["create field at A1;"]
    ["create field #myfield at A1;"]
    ["create field #myfield at A1..B2;"]
    ["create field #myfield at *;"]
    # ["set debug to false;"]
    # ["set grid to G5;"]
    # ["set debug to true;"]
    # ["select fields #myfield:                       set top border to 'thin, blue';"]
    # ["select fields #myfield, #thatone, .h, A1..B2: set top border to 'thin, blue';"]
    # ["select fields .caption:                       set horizontal alignment to left;"]
    ]
  #.........................................................................................................
  for [ probe, matcher, ] in probes_and_matchers
    parser = new NEARLEY.Parser NEARLEY.Grammar.fromCompiled G
    try
      parser.feed probe
    catch error
      throw error
      T.fail error.message
      continue
    result = parser.results
    urge '36633', ( jr [ probe, result, ] )
    # T.eq result, matcher
  #.........................................................................................................
  done()



############################################################################################################
unless module.parent?
  include = [
    "basic"
    ]
  @_prune()
  @_main()








