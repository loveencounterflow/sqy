

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
badge                     = 'SQY/GRAMMAR/TESTS'
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
SQY                       = require '../sqy'
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
    ["set debug to true;",{"type":"set_debug","value":true,"loc":"1#1"}]
    ["set debug to true ;",{"type":"set_debug","value":true,"loc":"1#1"}]
    ["set  debug to true;",{"type":"set_debug","value":true,"loc":"1#1"}]
    ["set  debug to true; ",{"type":"set_debug","value":true,"loc":"1#1"}]
    ["set  debug to true ;",{"type":"set_debug","value":true,"loc":"1#1"}]
    ["set  debug to true  ;",{"type":"set_debug","value":true,"loc":"1#1"}]
    [" set debug to true ;",{"type":"set_debug","value":true,"loc":"1#2"}]
    ["setdebugto",null]
    ["setdebugtotrue",null]
    ["setdebugtotrue;",null]
    [" set debug to true ; ",{"type":"set_debug","value":true,"loc":"1#2"}]
    ["  set   debug   to   true ; ",{"type":"set_debug","value":true,"loc":"1#3"}]
    ["  select   fields #myfield;",{"type":"select_fields","selectors":[{"type":"id","id":"#myfield"}],"loc":"1#3"}]
    ["select fields #myfield;",{"type":"select_fields","selectors":[{"type":"id","id":"#myfield"}],"loc":"1#1"}]
    ["select  fields #myfield;",{"type":"select_fields","selectors":[{"type":"id","id":"#myfield"}],"loc":"1#1"}]
    ["create layout #mylayout;",{"type":"create_layout","id":"#mylayout","loc":"1#1"}]
    ["create field at A1;",{"type":"create_field","id":null,"selector":{"type":"cellkey","value":"A1"},"loc":"1#1"}]
    ["create field #myfield at A1;",{"type":"create_field","id":"#myfield","selector":{"type":"cellkey","value":"A1"},"loc":"1#1"}]
    ["create field #myfield at A1..B2;",{"type":"create_field","id":"#myfield","selector":{"type":"rangekey","first":{"type":"cellkey","value":"A1"},"second":{"type":"cellkey","value":"B2"}},"loc":"1#1"}]
    ["create field #myfield at *;",{"type":"create_field","id":"#myfield","selector":{"type":"cellkey","value":"*"},"loc":"1#1"}]
    ["set debug to false;",{"type":"set_debug","value":false,"loc":"1#1"}]
    ["set grid to G5;",{"type":"set_grid","size":{"type":"cellkey","value":"G5"},"loc":"1#1"}]
    ["select D3;",null]
    ["select fields D3;",{"type":"select_fields","selectors":[{"type":"cellkey","value":"D3"}],"loc":"1#1"}]
    ["select fields D3..E6;",{"type":"select_fields","selectors":[{"type":"rangekey","first":{"type":"cellkey","value":"D3"},"second":{"type":"cellkey","value":"E6"}}],"loc":"1#1"}]
    ["select fields D12..E34,AA11;",{"type":"select_fields","selectors":[{"type":"rangekey","first":{"type":"cellkey","value":"D12"},"second":{"type":"cellkey","value":"E34"}},{"type":"cellkey","value":"AA11"}],"loc":"1#1"}]
    ["select fields D12..E34, AA11;",{"type":"select_fields","selectors":[{"type":"rangekey","first":{"type":"cellkey","value":"D12"},"second":{"type":"cellkey","value":"E34"}},{"type":"cellkey","value":"AA11"}],"loc":"1#1"}]
    ["select fields #myfield;",{"type":"select_fields","selectors":[{"type":"id","id":"#myfield"}],"loc":"1#1"}]
    ["set $foobar to 'some text';",{"type":"assignment","id":"$foobar","rhs":{"type":"text","value":"some text"},"loc":"1#1"}]
    ["set $foobar to +1.2334;",{"type":"assignment","id":"$foobar","rhs":{"type":"number","value":1.2334},"loc":"1#1"}]
    ["set top border to 'thin, blue';",{"type":"set_ctx_border","edges":["top"],"style":"thin, blue","loc":"1#1"}]
    ["set top, bottom border to 'thin, blue';",{"type":"set_ctx_border","edges":["top","bottom"],"style":"thin, blue","loc":"1#1"}]
    ["set all, bottom border to 'thin, blue';",{"type":"set_ctx_border","edges":["all","bottom"],"style":"thin, blue","loc":"1#1"}]
    ["set all border to 'thin, blue';",{"type":"set_ctx_border","edges":["all"],"style":"thin, blue","loc":"1#1"}]
    ["set top, bottom borders to 'thin, blue';",{"type":"set_ctx_border","edges":["top","bottom"],"style":"thin, blue","loc":"1#1"}]
    ["set all borders to 'thin, blue';",{"type":"set_ctx_border","edges":["all"],"style":"thin, blue","loc":"1#1"}]
    ["set top border of C3 to 'thin, blue';",{"type":"set_sel_border","edges":["top"],"selectors":[{"type":"cellkey","value":"C3"}],"style":"thin, blue","loc":"1#1"}]
    ["set top border of C3, D4 to 'red';",{"type":"set_sel_border","edges":["top"],"selectors":[{"type":"cellkey","value":"C3"},{"type":"cellkey","value":"D4"}],"style":"red","loc":"1#1"}]
    ["set top border of #thatfield to 'thick';",{"type":"set_sel_border","edges":["top"],"selectors":[{"type":"id","id":"#thatfield"}],"style":"thick","loc":"1#1"}]
    ["select fields #myfield;                       set top border to 'thin, blue';",[{"type":"select_fields","selectors":[{"type":"id","id":"#myfield"}],"loc":"1#1"},{"type":"set_ctx_border","edges":["top"],"style":"thin, blue","loc":"1#47"}]]
    ["select fields #myfield;                       set top border to 'thin, blue';",[{"type":"select_fields","selectors":[{"type":"id","id":"#myfield"}],"loc":"1#1"},{"type":"set_ctx_border","edges":["top"],"style":"thin, blue","loc":"1#47"}]]
    ["select fields #myfield, #thatone, A1..B2;     set all borders to 'thin';",[{"type":"select_fields","selectors":[{"type":"id","id":"#myfield"},{"type":"id","id":"#thatone"},{"type":"rangekey","first":{"type":"cellkey","value":"A1"},"second":{"type":"cellkey","value":"B2"}}],"loc":"1#1"},{"type":"set_ctx_border","edges":["all"],"style":"thin","loc":"1#47"}]]
    ]
  #.........................................................................................................
  for [ probe, matcher, ] in probes_and_matchers
    try
      result = SQY.parse probe
    catch error
      # throw error
      if matcher is null
        T.ok true
        help '36633', ( jr [ probe, null, ] )
      else
        T.fail error.message
        warn '36633', ( jr [ probe, null, ] )
      continue
    urge '36633', ( jr [ probe, result, ] )
    T.eq result, matcher
  #.........................................................................................................
  done()

#-----------------------------------------------------------------------------------------------------------
@[ "nl" ] = ( T, done ) ->
  probes_and_matchers = [
    [" \n set debug to true ;",{"type":"set_debug","value":true,"loc":"2#2"}]
    [" set debug to true ; \n  select fields #thatone;",[{"type":"set_debug","value":true,"loc":"1#2"},{"type":"select_fields","selectors":[{"type":"id","id":"#thatone"}],"loc":"1#25"}]]
    ["  set   debug   to   true ; \n  select fields #thatone;",[{"type":"set_debug","value":true,"loc":"1#3"},{"type":"select_fields","selectors":[{"type":"id","id":"#thatone"}],"loc":"1#32"}]]
    ["  select   fields #myfield;\n  select fields #thatone;",[{"type":"select_fields","selectors":[{"type":"id","id":"#myfield"}],"loc":"1#3"},{"type":"select_fields","selectors":[{"type":"id","id":"#thatone"}],"loc":"1#31"}]]
    ]
  #.........................................................................................................
  for [ probe, matcher, ] in probes_and_matchers
    try
      result = SQY.parse probe
    catch error
      # throw error
      if matcher is null
        T.ok true
        help '36633', ( jr [ probe, null, ] )
      else
        T.fail error.message
        warn '36633', ( jr [ probe, null, ] )
      continue
    urge '36633', ( jr [ probe, result, ] )
    T.eq result, matcher
  #.........................................................................................................
  done()

#-----------------------------------------------------------------------------------------------------------
@[ "alignment" ] = ( T, done ) ->
  probes_and_matchers = [
    ["set top, bottom border to 'thin, blue';",{"type":"set_ctx_border","edges":["top","bottom"],"style":"thin, blue","loc":"1#1"}]
    ["set vertical   alignment of #overlap-topright,    #overlap-topleft      to top;",{"type":"set_sel_alignment","selectors":[{"type":"id","id":"#overlap-topright"},{"type":"id","id":"#overlap-topleft"}],"direction":"vertical","align":"top","loc":"1#1"}]
    ["set valign of #overlap-topright,    #overlap-topleft      to top;",{"type":"set_sel_alignment","selectors":[{"type":"id","id":"#overlap-topright"},{"type":"id","id":"#overlap-topleft"}],"direction":"vertical","align":"top","loc":"1#1"}]
    ["set horizontal alignment of #overlap-topright,    #overlap-topleft      to top;",null]
    ["set halign to left;",{"type":"set_ctx_alignment","direction":"horizontal","align":"left","loc":"1#1"}]
    ["set valign to bottom;",{"type":"set_ctx_alignment","direction":"vertical","align":"bottom","loc":"1#1"}]
    # ["select fields .caption;                       set horizontal alignment to left;"]
    # ["select cells D3..E6; create field #myfield; set border to 'thin'; set halign to center;"]
    ]
  #.........................................................................................................
  for [ probe, matcher, ] in probes_and_matchers
    try
      result = SQY.parse probe
    catch error
      # throw error
      if matcher is null
        T.ok true
        help '36633', ( jr [ probe, null, ] )
      else
        T.fail error.message
        warn '36633', ( jr [ probe, null, ] )
      continue
    urge '36633', ( jr [ probe, result, ] )
    T.eq result, matcher
  #.........................................................................................................
  done()

#-----------------------------------------------------------------------------------------------------------
@[ "comments" ] = ( T, done ) ->
  probes_and_matchers = [
    ["set valign to bottom; # just a comment",[{"type":"set_ctx_alignment","direction":"vertical","align":"bottom","loc":"1#1"}]]
    ["# just a comment",[]]
    ["  # just a comment   ",[]]
    ["  # three\n# comments\n# in a row",[]]
    ["  # three\n   # comments\n   # in a row",[]]
    # ["select fields .caption;                       set horizontal alignment to left;"]
    # ["select cells D3..E6; create field #myfield; set border to 'thin'; set halign to center;"]
    ]
  #.........................................................................................................
  for [ probe, matcher, ] in probes_and_matchers
    try
      result = SQY.parse probe
    catch error
      # throw error
      if matcher is null
        T.ok true
        help '36633', ( jr [ probe, null, ] )
      else
        T.fail error.message
        warn '36633', ( jr [ probe, null, ] )
      continue
    urge '36633', ( jr [ probe, result, ] )
    T.eq result, matcher
  #.........................................................................................................
  done()

#-----------------------------------------------------------------------------------------------------------
@[ "cheats" ] = ( T, done ) ->
  probes_and_matchers = [
    ["!cheat;",{"type":"cheat"}]
    ["  set debug to true;\n  !cheat;\n\n  create field #japanese-text         at A1..A4;\n",[{"type":"set_debug","value":true,"loc":"1#3"},{"type":"cheat"},{"type":"create_field","id":"#japanese-text","selector":{"type":"rangekey","first":{"type":"cellkey","value":"A1"},"second":{"type":"cellkey","value":"A4"}},"loc":"1#35"}]]
    ]
  #.........................................................................................................
  for [ probe, matcher, ] in probes_and_matchers
    try
      result = SQY.parse probe
    catch error
      # throw error
      if matcher is null
        T.ok true
        help '36633', ( jr [ probe, null, ] )
      else
        T.fail error.message
        warn '36633', ( jr [ probe, null, ] )
      continue
    urge '36633', ( jr [ probe, result, ] )
    T.eq result, matcher
  #.........................................................................................................
  done()

#-----------------------------------------------------------------------------------------------------------
@[ "units" ] = ( T, done ) ->
  probes_and_matchers = [
    ["set unit  to 1mm;",{"type":"set_unit_lengths","value":1,"unit":"mm"}]
    ]
  #.........................................................................................................
  for [ probe, matcher, ] in probes_and_matchers
    try
      result = SQY.parse probe
    catch error
      # throw error
      if matcher is null
        T.ok true
        help '36633', ( jr [ probe, null, ] )
      else
        T.fail error.message
        warn '36633', ( jr [ probe, null, ] )
      continue
    urge '36633', ( jr [ probe, result, ] )
    T.eq result, matcher
  #.........................................................................................................
  done()



############################################################################################################
unless module.parent?
  include = [
    "basic"
    "nl"
    "alignment"
    # "comments"
    "cheats"
    "units"
    ]
  @_prune()
  @_main()










