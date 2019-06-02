

'use strict'


############################################################################################################
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'SQY/TESTS/MAIN'
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

L = @
for path in [ './sqy-lexer.test.js', './sqy-grammar.test.js', ]
  debug 'µ28883', path
  module = require path
  for name, value of module
    if CND.isa_function value
      L[ name ] = value.bind L
    else
      L[ name ] = value
  test L




