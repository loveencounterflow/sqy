

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
    ["create layout #mylayout;",[{"type":"create_layout","id":"#mylayout","loc":"1#1"}]]
    ["create field at A1;",[{"type":"create_field","id":null,"selector":{"type":"cellkey","value":"A1"},"loc":"1#1"}]]
    ["create field #myfield at A1;",[{"type":"create_field","id":"#myfield","selector":{"type":"cellkey","value":"A1"},"loc":"1#1"}]]
    ["create field #myfield at A1..B2;",[{"type":"create_field","id":"#myfield","selector":{"type":"rangekey","first":{"type":"cellkey","value":"A1"},"second":{"type":"cellkey","value":"B2"}},"loc":"1#1"}]]
    ["create field #myfield at *;",[{"type":"create_field","id":"#myfield","selector":{"type":"cellkey","value":"*"},"loc":"1#1"}]]
    ["set debug to false;",[{"type":"set_debug","value":false,"loc":"1#1"}]]
    ["set grid to G5;",[{"type":"set_grid","size":{"type":"cellkey","value":"G5"},"loc":"1#1"}]]
    ["set debug to true;",[{"type":"set_debug","value":true,"loc":"1#1"}]]
    ["select D3;",null]
    ["select fields D3;",[{"type":"select_fields","selectors":[{"type":"cellkey","value":"D3"}],"loc":"1#1"}]]
    ["select fields D3..E6;",[{"type":"select_fields","selectors":[{"type":"rangekey","first":{"type":"cellkey","value":"D3"},"second":{"type":"cellkey","value":"E6"}}],"loc":"1#1"}]]
    ["select fields D12..E34,AA11;",[{"type":"select_fields","selectors":[{"type":"rangekey","first":{"type":"cellkey","value":"D12"},"second":{"type":"cellkey","value":"E34"}},{"type":"cellkey","value":"AA11"}],"loc":"1#1"}]]
    ["select fields D12..E34, AA11;",[{"type":"select_fields","selectors":[{"type":"rangekey","first":{"type":"cellkey","value":"D12"},"second":{"type":"cellkey","value":"E34"}},{"type":"cellkey","value":"AA11"}],"loc":"1#1"}]]
    ["select fields #myfield;",[{"type":"select_fields","selectors":[{"type":"id","id":"#myfield"}],"loc":"1#1"}]]
    ["set $foobar to 'some text';",[{"type":"set_vname","id":"$foobar","value":"some text","loc":"1#1"}]]
    # ["set top border to 'thin, blue';"]
    # ["select fields #myfield;                       set top border to 'thin, blue';"]
    # ["select fields #myfield;                       set top border to 'thin, blue';"]
    # ["select fields #myfield, #thatone, .h, A1..B2; set top border to 'thin, blue';"]
    # ["select fields .caption;                       set horizontal alignment to left;"]

    # ["select cells D3..E6; create field #myfield; set border to 'thin'; set halign to center;"]
    ]
  #.........................................................................................................
  for [ probe, matcher, ] in probes_and_matchers
    parser = new NEARLEY.Parser NEARLEY.Grammar.fromCompiled G
    try
      parser.feed probe
    catch error
      # throw error
      if matcher is null then T.ok true else T.fail error.message
      warn '36633', ( jr [ probe, null, ] )
      continue
    result = parser.results
    urge '36633', ( jr [ probe, result, ] )
    T.eq result, matcher
  #.........................................................................................................
  done()



############################################################################################################
unless module.parent?
  include = [
    "basic"
    ]
  @_prune()
  @_main()








