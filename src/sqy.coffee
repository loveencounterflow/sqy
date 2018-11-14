
'use strict'

############################################################################################################
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'SQY'
log                       = CND.get_logger 'plain',     badge
info                      = CND.get_logger 'info',      badge
whisper                   = CND.get_logger 'whisper',   badge
alert                     = CND.get_logger 'alert',     badge
debug                     = CND.get_logger 'debug',     badge
warn                      = CND.get_logger 'warn',      badge
help                      = CND.get_logger 'help',      badge
urge                      = CND.get_logger 'urge',      badge
echo                      = CND.echo.bind CND
NEARLEY                   = require 'nearley'

#-----------------------------------------------------------------------------------------------------------
@lexer                    = ( require './sqy-lexer' ).lexer
@grammar                  = require './sqy-grammar'

#-----------------------------------------------------------------------------------------------------------
@parse = ( source ) ->
  parser = new NEARLEY.Parser NEARLEY.Grammar.fromCompiled @grammar
  parser.feed source
  R = parser.results
  throw new Error "µ55891 detected ambiguous grammar #{rpr R}" unless R.length is 1
  return R[ 0 ]




