




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
LXR                       = require '../sqlish-lexer'
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
    # ["create field at A1..B2;","create,field,at,rowletters/'A',coldigits/'1',upto/'..',rowletters/'B',coldigits/'2',semicolon/';'"]
    # ["set grid to G5;","set,grid,to,rowletters/'G',coldigits/'5',semicolon/';'"]
    # ["set debug to false;","set,name/'debug',to,boolean/'false',semicolon/';'"]
    # ["create field at A1;","create,field,at,rowletters/'A',coldigits/'1',semicolon/';'"]
    # ["create field at A1..B2;","create,field,at,rowletters/'A',coldigits/'1',upto/'..',rowletters/'B',coldigits/'2',semicolon/';'"]
    # ["create field #myfield at A1..B2;","create,field,id/'#myfield',at,rowletters/'A',coldigits/'1',upto/'..',rowletters/'B',coldigits/'2',semicolon/';'"]
    # ["select fields #myfield:                       set top border to 'thin, blue';","select,fields,id/'#myfield',colon/':',set,edge/'top',border,to,sq_string/'\\'thin, blue\\'',semicolon/';'"]
    # ["select fields #myfield, #thatone, .h, A1..B2: set top border to 'thin, blue';","select,fields,id/'#myfield',comma/',',id/'#thatone',comma/',',clasz/'.h',comma/',',rowletters/'A',coldigits/'1',upto/'..',rowletters/'B',coldigits/'2',colon/':',set,edge/'top',border,to,sq_string/'\\'thin, blue\\'',semicolon/';'"]
    # ["select fields .caption:                       set horizontal alignment to left;","select,fields,clasz/'.caption',colon/':',set,halign/'horizontal alignment',to,edge/'left',semicolon/';'"]
    # ["select fields .caption:                       set valign to top;","select,fields,clasz/'.caption',colon/':',set,valign,to,edge/'top',semicolon/';'"]
    # ["select fields *1: set valign to top;","select,fields,lonestar/'*',coldigits/'1',colon/':',set,valign,to,edge/'top',semicolon/';'"]
    # ["select fields **: set valign to top;","select,fields,dubstar/'**',colon/':',set,valign,to,edge/'top',semicolon/';'"]
    # ["select fields **..**: set valign to top;","select,fields,dubstar/'**',upto/'..',dubstar/'**',colon/':',set,valign,to,edge/'top',semicolon/';'"]
    # ["select fields *: set valign to top;","select,fields,lonestar/'*',colon/':',set,valign,to,edge/'top',semicolon/';'"]
    ]
  #.........................................................................................................
  for [ probe, matcher, ] in probes_and_matchers
    LXR.lexer.reset probe
    result = []
    try
      while ( token = LXR.lexer.next() )?
        unless token.type is 'lws'
          if token.type is token.value
            result.push "#{token.type}"
          else
            result.push "#{token.type}/#{rpr token.value}"
    catch error
      T.fail error.message
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
    ]
  @_prune()
  @_main()








