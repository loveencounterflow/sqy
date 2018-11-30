

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
show = ( ref, probe, ast ) ->
  ast_txt = _pen_ast ast
  info ( _pen_ast ast ) + ' ' + ( CND.grey ref ) + ' ' + ( CND.grey rpr probe )

#-----------------------------------------------------------------------------------------------------------
_pen_ast = ( ast ) ->
  R = []
  #.........................................................................................................
  if CND.isa_list ast
    for t in ast
      #.....................................................................................................
      if CND.isa_list t
        for sub_token in t
          R.push _pen_ast sub_token
      #.....................................................................................................
      else
        R.push _pen_token t
  #.........................................................................................................
  else
    R.push _pen_token ast
  #.........................................................................................................
  return R.join ' '

#-----------------------------------------------------------------------------------------------------------
_pen_token = ( token ) ->
  # whisper token
  return ( CND.grey '#' )             if token is null
  return ( CND.grey '.' )             if token.type in [ 'ws', ]
  return ( CND.grey 'n' )             if token.type in [ 'nl', ]
  return ( CND.grey rpr token.value ) if token.type in [ 'semicolon', ]
  return ( CND.orange token.value )   if token.type is token.value and token.type isnt undefined
  return ( CND.plum token.type ) + '/' + ( CND.white rpr token.value )


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
    ["create layout #mylayout;",{"type":"create_layout","id":"#mylayout","loc":"1#1"}]
    ["create field at A1;",{"type":"create_field","id":null,"selector":{"type":"cellkey","value":"A1"},"loc":"1#1"}]
    ["create field #myfield at A1;",{"type":"create_field","id":"#myfield","selector":{"type":"cellkey","value":"A1"},"loc":"1#1"}]
    ["create field #myfield at A1..B2;",{"type":"create_field","id":"#myfield","selector":{"type":"rangekey","first":{"type":"cellkey","value":"A1"},"second":{"type":"cellkey","value":"B2"}},"loc":"1#1"}]
    ["create field #myfield at *;",{"type":"create_field","id":"#myfield","selector":{"type":"cellkey","value":"*"},"loc":"1#1"}]
    ["set debug to false;",{"type":"set_debug","value":false,"loc":"1#1"}]
    ["set grid to G5;",{"type":"set_grid","size":{"type":"cellkey","value":"G5"},"loc":"1#1"}]
    ["select D3;",null]
    ["set $foobar to 'some text';",{"type":"assignment","id":"$foobar","rhs":{"type":"text","value":"some text"},"loc":"1#1"}]
    ["set $foobar to +1.2334;",{"type":"assignment","id":"$foobar","rhs":{"type":"number","value":1.2334},"loc":"1#1"}]
    ["set top border of C3 to 'thin, blue';",{"type":"set_sel_border","edges":["top"],"selectors":[{"type":"cellkey","value":"C3"}],"style":"thin, blue","loc":"1#1"}]
    ["set top border of C3, D4 to 'red';",{"type":"set_sel_border","edges":["top"],"selectors":[{"type":"cellkey","value":"C3"},{"type":"cellkey","value":"D4"}],"style":"red","loc":"1#1"}]
    ["set top border of #thatfield to 'thick';",{"type":"set_sel_border","edges":["top"],"selectors":[{"type":"id","id":"#thatfield"}],"style":"thick","loc":"1#1"}]
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
    # show '36633', probe, result
    urge '36633', ( jr [ probe, result, ] )
    T.eq result, matcher
  #.........................................................................................................
  done()

#-----------------------------------------------------------------------------------------------------------
@[ "nl" ] = ( T, done ) ->
  probes_and_matchers = [
    [" \n set debug to true ;",{"type":"set_debug","value":true,"loc":"2#2"}]
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
    # show '36633', probe, result
    urge '36633', ( jr [ probe, result, ] )
    T.eq result, matcher
  #.........................................................................................................
  done()

#-----------------------------------------------------------------------------------------------------------
@[ "alignment" ] = ( T, done ) ->
  probes_and_matchers = [
    ["set vertical   alignment of #overlap-topright,    #overlap-topleft      to top;",{"type":"set_sel_alignment","selectors":[{"type":"id","id":"#overlap-topright"},{"type":"id","id":"#overlap-topleft"}],"direction":"vertical","align":"top","loc":"1#1"}]
    ["set horizontal alignment of #overlap-topright,    #overlap-topleft      to top;",null]
    ["set horizontal alignment of #overlap-topright,    #overlap-topleft      to left;",{"type":"set_sel_alignment","selectors":[{"type":"id","id":"#overlap-topright"},{"type":"id","id":"#overlap-topleft"}],"direction":"horizontal","align":"left","loc":"1#1"}]
    ["set valign of #overlap-topright,    #overlap-topleft      to top;",{"type":"set_sel_alignment","selectors":[{"type":"id","id":"#overlap-topright"},{"type":"id","id":"#overlap-topleft"}],"direction":"vertical","align":"top","loc":"1#1"}]
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
    # show '36633', probe, result
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
    # show '36633', probe, result
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
    # show '36633', probe, result
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
    # show '36633', probe, result
    urge '36633', ( jr [ probe, result, ] )
    T.eq result, matcher
  #.........................................................................................................
  done()

#-----------------------------------------------------------------------------------------------------------
@[ "lane sizes" ] = ( T, done ) ->
  probes_and_matchers = [
    ["set col width to 10;",{"type":"set_lane_sizes","lane":"col","direction":"width","value":10}]
    ["set col widths to 10;",{"type":"set_lane_sizes","lane":"col","direction":"width","value":10}]
    ["set column width to 10;",{"type":"set_lane_sizes","lane":"col","direction":"width","value":10}]
    ["set column widths to 10;",{"type":"set_lane_sizes","lane":"col","direction":"width","value":10}]
    ["set row height to 10;",{"type":"set_lane_sizes","lane":"row","direction":"height","value":10}]
    ["set row heights to 10;",{"type":"set_lane_sizes","lane":"row","direction":"height","value":10}]
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
    # show '36633', probe, result
    urge '36633', ( jr [ probe, result, ] )
    T.eq result, matcher
  #.........................................................................................................
  done()

#-----------------------------------------------------------------------------------------------------------
@[ "_deprecated" ] = ( T, done ) ->
  probes_and_matchers = [
    ["  select   fields #myfield;",{"type":"select_fields","selectors":[{"type":"id","id":"#myfield"}],"loc":"1#3"}]
    ["select fields #myfield;",{"type":"select_fields","selectors":[{"type":"id","id":"#myfield"}],"loc":"1#1"}]
    ["select  fields #myfield;",{"type":"select_fields","selectors":[{"type":"id","id":"#myfield"}],"loc":"1#1"}]
    ["select fields D3;",{"type":"select_fields","selectors":[{"type":"cellkey","value":"D3"}],"loc":"1#1"}]
    ["select fields D3..E6;",{"type":"select_fields","selectors":[{"type":"rangekey","first":{"type":"cellkey","value":"D3"},"second":{"type":"cellkey","value":"E6"}}],"loc":"1#1"}]
    ["select fields D12..E34,AA11;",{"type":"select_fields","selectors":[{"type":"rangekey","first":{"type":"cellkey","value":"D12"},"second":{"type":"cellkey","value":"E34"}},{"type":"cellkey","value":"AA11"}],"loc":"1#1"}]
    ["select fields D12..E34, AA11;",{"type":"select_fields","selectors":[{"type":"rangekey","first":{"type":"cellkey","value":"D12"},"second":{"type":"cellkey","value":"E34"}},{"type":"cellkey","value":"AA11"}],"loc":"1#1"}]
    ["select fields #myfield;",{"type":"select_fields","selectors":[{"type":"id","id":"#myfield"}],"loc":"1#1"}]
    ["select fields #myfield;                       set top border to 'thin, blue';",[{"type":"select_fields","selectors":[{"type":"id","id":"#myfield"}],"loc":"1#1"},{"type":"set_ctx_border","edges":["top"],"style":"thin, blue","loc":"1#47"}]]
    ["select fields #myfield;                       set top border to 'thin, blue';",[{"type":"select_fields","selectors":[{"type":"id","id":"#myfield"}],"loc":"1#1"},{"type":"set_ctx_border","edges":["top"],"style":"thin, blue","loc":"1#47"}]]
    ["select fields #myfield, #thatone, A1..B2;     set all borders to 'thin';",[{"type":"select_fields","selectors":[{"type":"id","id":"#myfield"},{"type":"id","id":"#thatone"},{"type":"rangekey","first":{"type":"cellkey","value":"A1"},"second":{"type":"cellkey","value":"B2"}}],"loc":"1#1"},{"type":"set_ctx_border","edges":["all"],"style":"thin","loc":"1#47"}]]
    [" set debug to true ; \n  select fields #thatone;",[{"type":"set_debug","value":true,"loc":"1#2"},{"type":"select_fields","selectors":[{"type":"id","id":"#thatone"}],"loc":"1#25"}]]
    ["  set   debug   to   true ; \n  select fields #thatone;",[{"type":"set_debug","value":true,"loc":"1#3"},{"type":"select_fields","selectors":[{"type":"id","id":"#thatone"}],"loc":"1#32"}]]
    ["  select   fields #myfield;\n  select fields #thatone;",[{"type":"select_fields","selectors":[{"type":"id","id":"#myfield"}],"loc":"1#3"},{"type":"select_fields","selectors":[{"type":"id","id":"#thatone"}],"loc":"1#31"}]]
    ["set top border to 'thin, blue';",{"type":"set_ctx_border","edges":["top"],"style":"thin, blue","loc":"1#1"}]
    ["set top, bottom border to 'thin, blue';",{"type":"set_ctx_border","edges":["top","bottom"],"style":"thin, blue","loc":"1#1"}]
    ["set all, bottom border to 'thin, blue';",{"type":"set_ctx_border","edges":["all","bottom"],"style":"thin, blue","loc":"1#1"}]
    ["set all border to 'thin, blue';",{"type":"set_ctx_border","edges":["all"],"style":"thin, blue","loc":"1#1"}]
    ["set top, bottom borders to 'thin, blue';",{"type":"set_ctx_border","edges":["top","bottom"],"style":"thin, blue","loc":"1#1"}]
    ["set all borders to 'thin, blue';",{"type":"set_ctx_border","edges":["all"],"style":"thin, blue","loc":"1#1"}]
    ["set top, bottom border to 'thin, blue';",{"type":"set_ctx_border","edges":["top","bottom"],"style":"thin, blue","loc":"1#1"}]
    ["set halign to left;",{"type":"set_ctx_alignment","direction":"horizontal","align":"left","loc":"1#1"}]
    ["set valign to bottom;",{"type":"set_ctx_alignment","direction":"vertical","align":"bottom","loc":"1#1"}]
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
    # show '36633', probe, result
    urge '36633', ( jr [ probe, result, ] )
    # T.eq result, matcher
  #.........................................................................................................
  done()

#-----------------------------------------------------------------------------------------------------------
@[ "gaps" ] = ( T, done ) ->
  probes_and_matchers = [
    ["set default border gaps   to 0;",{"type":"set_default_gaps","feature":"border","value":0}]
    ["set default text gaps     to 1;",{"type":"set_default_gaps","feature":"text","value":1}]
    ["set default background gaps     to 1;",{"type":"set_default_gaps","feature":"background","value":1}]
    ["set default border gap   to 0;",{"type":"set_default_gaps","feature":"border","value":0}]
    ["set default text gap     to 1;",{"type":"set_default_gaps","feature":"text","value":1}]
    ["set default background gap     to 1;",{"type":"set_default_gaps","feature":"background","value":1}]
    ["set left, right border gaps of A1   to 0;",{"type":"set_field_gaps","edges":["left","right"],"feature":"border","selectors":[{"type":"cellkey","value":"A1"}],"value":0}]
    ["set left, right text gaps of A1, #xy, D2..E4 to 1.5;",{"type":"set_field_gaps","edges":["left","right"],"feature":"text","selectors":[{"type":"cellkey","value":"A1"},{"type":"id","id":"#xy"},{"type":"rangekey","first":{"type":"cellkey","value":"D2"},"second":{"type":"cellkey","value":"E4"}}],"value":1.5}]
    ["set left, right background gaps of A1     to 1;",{"type":"set_field_gaps","edges":["left","right"],"feature":"background","selectors":[{"type":"cellkey","value":"A1"}],"value":1}]
    ["set left, right border gap of A1   to 0;",{"type":"set_field_gaps","edges":["left","right"],"feature":"border","selectors":[{"type":"cellkey","value":"A1"}],"value":0}]
    ["set left, right text gap of A1     to 1;",{"type":"set_field_gaps","edges":["left","right"],"feature":"text","selectors":[{"type":"cellkey","value":"A1"}],"value":1}]
    ["set left, right background gap of A1     to 1;",{"type":"set_field_gaps","edges":["left","right"],"feature":"background","selectors":[{"type":"cellkey","value":"A1"}],"value":1}]
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
    # show '36633', probe, result
    urge '36633', ( jr [ probe, result, ] )
    T.eq result, matcher
  #.........................................................................................................
  done()

#-----------------------------------------------------------------------------------------------------------
@[ "units" ] = ( T, done ) ->
  probes_and_matchers = [
    ["set unit              to mm;",{"type":"set_unit_lengths","direction":"both","value":1,"unit":"mm"}]
    ["set unit              to 5.26mm;",{"type":"set_unit_lengths","direction":"both","value":5.26,"unit":"mm"}]
    ["set unit              to 1\\mktsLineheight;",{"type":"set_unit_lengths","direction":"both","value":1,"unit":"\\mktsLineheight"}]
    ["set unit              to \\mktsLineheight;",{"type":"set_unit_lengths","direction":"both","value":1,"unit":"\\mktsLineheight"}]
    ["set horizontal unit to 50mm;",{"type":"set_unit_lengths","direction":"horizontal","value":50,"unit":"mm"}]
    ["set horizontal unit to \\linewidth;",{"type":"set_unit_lengths","direction":"horizontal","value":1,"unit":"\\linewidth"}]
    ["set vertical   unit to 5\\mktsLineheight;",{"type":"set_unit_lengths","direction":"vertical","value":5,"unit":"\\mktsLineheight"}]
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
        throw error
        T.fail error.message
        warn '36633', ( jr [ probe, null, ] )
      continue
    # show '36633', probe, result
    urge '36633', ( jr [ probe, result, ] )
    T.eq result, matcher
  #.........................................................................................................
  done()

#-----------------------------------------------------------------------------------------------------------
@[ "sample" ] = ( T, done ) ->
  probes_and_matchers = [
    ["""
  create layout #kwic-guide-head;
  set debug             to true;
  set grid              to A1;
  set column widths     to 50;
  set row heights       to 10;
  set default text gap  to 2;
  create field #guide at A1;
  set all borders of * to 'sThin';
  set valign of * to center;
  set halign of * to center;
  """,{"type":"set_default_gaps","feature":"border","value":0}]
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
    # show '36633', probe, result
    urge '36633', ( jr [ probe, result, ] )
    # T.eq result, matcher
  #.........................................................................................................
  done()



############################################################################################################
unless module.parent?
  include = [
    "alignment"
    "basic"
    "nl"
    # "comments"
    "cheats"
    "units"
    "lane sizes"
    "gaps"
    "sample"
    "units"
    ]
  @_prune()
  @_main()










