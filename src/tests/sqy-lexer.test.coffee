




'use strict'


############################################################################################################
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'SQY/LEXER/TESTS'
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
LXR                       = require '../sqy-lexer'
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
    ["create layout #mylayout;","create,layout,id/'#mylayout',semicolon/';'"]
    ["create field at A1..B2;","create,field,at,cellkey/'A1',upto/'..',cellkey/'B2',semicolon/';'"]
    ["set grid to G5;","set,grid,to,cellkey/'G5',semicolon/';'"]
    ["set debug to false;","set,name/'debug',to,boolean/false,semicolon/';'"]
    ["create field at A1;","create,field,at,cellkey/'A1',semicolon/';'"]
    ["create field at A1..B2;","create,field,at,cellkey/'A1',upto/'..',cellkey/'B2',semicolon/';'"]
    ["create field #myfield at A1..B2;","create,field,id/'#myfield',at,cellkey/'A1',upto/'..',cellkey/'B2',semicolon/';'"]
    ["select fields #myfield:                       set top border to 'thin, blue';","select,fields,id/'#myfield',colon/':',set,top,border,to,sq_string/'thin, blue',semicolon/';'"]
    ["select fields #myfield, #thatone, .h, A1..B2: set top border to 'thin, blue';","select,fields,id/'#myfield',comma/',',id/'#thatone',comma/',',clasz/'.h',comma/',',cellkey/'A1',upto/'..',cellkey/'B2',colon/':',set,top,border,to,sq_string/'thin, blue',semicolon/';'"]
    ["select fields .caption:                       set horizontal alignment to left;","select,fields,clasz/'.caption',colon/':',set,horizontal,alignment,to,left,semicolon/';'"]
    ["select fields .caption:                       set valign to top;","select,fields,clasz/'.caption',colon/':',set,valign,to,top,semicolon/';'"]
    ["select fields *1: set valign to top;","select,fields,cellkey/'*1',colon/':',set,valign,to,top,semicolon/';'"]
    ["select fields *: set valign to top;","select,fields,cellkey/'*',colon/':',set,valign,to,top,semicolon/';'"]
    ["select fields *..*: set valign to top;","select,fields,cellkey/'*',upto/'..',cellkey/'*',colon/':',set,valign,to,top,semicolon/';'"]
    ["select fields *: set valign to top;","select,fields,cellkey/'*',colon/':',set,valign,to,top,semicolon/';'"]
    ["'some text'","sq_string/'some text'"]
    ["123456","integer/123456"]
    ["-123456","integer/-123456"]
    ["+123456","integer/123456"]
    ["12.55578","float/12.55578"]
    ["-12.55578","float/-12.55578"]
    ["+12.55578","float/12.55578"]
    ["-0.55578","float/-0.55578"]
    ["A1","cellkey/'A1'"]
    ["ABCD12345","cellkey/'ABCD12345'"]
    ["AC*","cellkey/'AC*'"]
    ["*","cellkey/'*'"]
    ["*3","cellkey/'*3'"]
    ["*-3","cellkey/'*-3'"]
    ["*+31","cellkey/'*+31'"]
    ["-CZ+31","cellkey/'-CZ+31'"]
    [ "cheat","name/'cheat'"]
    ["!cheat","cheat/'!cheat'"]
    ["# yadda","comment/'# yadda'"]
    ["set unit  to 1mm;","set,unit,to,integer/1,name/'mm',semicolon/';'"]
    ["set col width to 10;","set,col,width,to,integer/10,semicolon/';'"]
    ["set col widths to 10;","set,col,widths,to,integer/10,semicolon/';'"]
    ["set column width to 10;","set,column,width,to,integer/10,semicolon/';'"]
    ["set column widths to 10;","set,column,widths,to,integer/10,semicolon/';'"]
    ["set row height to 10;","set,row,height,to,integer/10,semicolon/';'"]
    ["set row heights to 10;","set,row,heights,to,integer/10,semicolon/';'"]
    ["set default border gaps   to 0;","set,default,border,gaps,to,integer/0,semicolon/';'"]
    ["set default text gaps     to 1;","set,default,text,gaps,to,integer/1,semicolon/';'"]
    ["set default background gaps     to 1;","set,default,background,gaps,to,integer/1,semicolon/';'"]
    ["set default border gap   to 0;","set,default,border,gap,to,integer/0,semicolon/';'"]
    ["set default text gap     to 1;","set,default,text,gap,to,integer/1,semicolon/';'"]
    ["set default background gap     to 1;","set,default,background,gap,to,integer/1,semicolon/';'"]
    ["set horizontal unit to 50mm;","set,horizontal,unit,to,integer/50,name/'mm',semicolon/';'"]
    ["set unit              to \\mktsLineheight;","set,unit,to,name/'\\\\mktsLineheight',semicolon/';'"]
    ### ["# yadda \nset $v to 123;","comment/'# yadda ',set,vname/'$v',to,integer/123,semicolon/';'"] ###
    ]
  #.........................................................................................................
  for [ probe, matcher, ] in probes_and_matchers
    LXR.lexer.reset probe
    result = []
    try
      while ( token = LXR.lexer.next() )?
        unless token.type is 'ws'
          if token.type is token.value
            result.push "#{token.type}"
          else
            result.push "#{token.type}/#{rpr token.value}"
    catch error
      T.fail error.message
      warn '44551', jr probe
      continue
    result = join result, ','
    urge '36633', ( jr [ probe, result, ] )
    T.eq result, matcher
  #.........................................................................................................
  done()

#-----------------------------------------------------------------------------------------------------------
@[ "nl" ] = ( T, done ) ->
  probes_and_matchers = [
    [" ","ws/' '"]
    ["\n","ws/'\\n'"]
    [" \n ","ws/' \\n '"]
    ]
  #.........................................................................................................
  for [ probe, matcher, ] in probes_and_matchers
    LXR.lexer.reset probe
    result = []
    try
      while ( token = LXR.lexer.next() )?
        if token.type is token.value
          result.push "#{token.type}"
        else
          result.push "#{token.type}/#{rpr token.value}"
    catch error
      T.fail error.message
      warn '44551', jr probe
      continue
    result = join result, ','
    urge '36633', ( jr [ probe, result, ] )
    T.eq result, matcher
  #.........................................................................................................
  done()



############################################################################################################
unless module.parent?
  include = [
    "basic"
    "nl"
    ]
  @_prune()
  @_main()








