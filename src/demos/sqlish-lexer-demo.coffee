

'use strict'

############################################################################################################
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'XXX/LEXING'
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
jr                        = JSON.stringify
assign                    = Object.assign
LXR                       = require '../sqlish-lexer'
join                      = ( x, joiner = '' ) -> x.join joiner



#-----------------------------------------------------------------------------------------------------------
colors =
  command:    CND.gold
  name:       CND.red
  id:         CND.green
  clasz:      CND.green
  dq_string:  ( P... ) -> CND.reverse CND.white CND.bold P...
  sq_string:  ( P... ) -> CND.reverse CND.white CND.bold P...
  boolean:    CND.blue
  # cellkey:    CND.blue
  # upto:       CND.blue
  # aux:        CND.yellow
  # comma:      ( P... ) -> CND.yellow CND.bold CND.reverse P...
  # colon:      ( P... ) -> CND.yellow CND.bold CND.reverse P...
  # semicolon:  ( P... ) -> CND.yellow CND.bold CND.reverse P...

sources = [
  "create field at A1..B2;"
  "create layout #mylayout;"
  "set grid to G5;"
  "set debug to false;"
  "create field at A1;"
  "create field at A1..B2;"
  "create field #myfield at A1..B2;"
  "select fields #myfield:                       set top border to 'thin, blue';"
  "select fields #myfield, #thatone, .h, A1..B2: set top border to 'thin, blue';"
  "select fields .caption:                       set horizontal alignment to left;"
  "select fields .caption:                       set valign to top;"
  "select fields *1: set valign to top;"
  "select fields **: set valign to top;"
  "select fields **..**: set valign to top;"
  "select fields *: set valign to top;"
  ]

for source in sources
  info rpr source
  LXR.lexer.reset source
  P = []
  try
    while ( token = LXR.lexer.next() )?
      unless token.type is 'lws'
        color   = colors[ token.type ] ? null
        color  ?= CND.gold if token.type is token.text
        color  ?= CND.white
        P.push join [ ( CND.grey token.type.padStart 15 ), ( color token.value ), ]
  catch error
    warn error.message
    # continue
    break
  echo join P, '\n'

# debug ( key for key of LXR.lexer )
help 'done'


