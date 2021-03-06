

'use strict'

############################################################################################################
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'SQY/LEXING'
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
# new_xregex                = require 'xregexp'
MOO                       = require 'moo'
words_of                  = ( text ) -> text.split /\s+/
join                      = ( x, joiner = '' ) -> x.join joiner

keywords = MOO.keywords {
  create:     'create'
  set:        'set'
  layout:     'layout'
  field:      'field'
  fields:     'fields'
  border:     'border'
  borders:    'borders'
  grid:       'grid'
  select:     'select'
  at:         'at'
  to:         'to'
  of:         'of'
  all:        'all'
  top:        'top'
  left:       'left'
  bottom:     'bottom'
  right:      'right'
  center:     'center'
  justified:  'justified'
  unit:       'unit'
  column:     'column'
  col:        'col'
  row:        'row'
  width:      'width'
  widths:     'widths'
  height:     'height'
  heights:    'heights'
  text:       'text'
  background: 'background'
  gap:        'gap'
  gaps:       'gaps'
  default:    'default'
  horizontal: 'horizontal'
  vertical:   'vertical'
  halign:     'halign'
  valign:     'valign'
  alignment:  'alignment'
  }

syntax =
  dq_string:        { match: /// " (?: \\[ " \\ ] | [^ \n " \\ ] )* " ///, value: ( ( s ) -> s[ 1 ... s.length - 1 ] ) }
  sq_string:        { match: /// ' (?: \\[ ' \\ ] | [^ \n ' \\ ] )* ' ///, value: ( ( s ) -> s[ 1 ... s.length - 1 ] ) }
  id:               /// \# [-_a-z0-9]+ ///
  clasz:            /// \. [-_a-z0-9]+ ///
  vname:            /// \$ [-_a-z0-9]+ ///
  boolean:          { match: ( words_of 'true false' ), value: ( ( s ) -> if s is 'true' then true else false ), }
  name:             { match: /// (?: \\ [_a-zA-Z] [-_a-zA-Z0-9]* | [_ a-z ] [-_a-z0-9]* ) ///, type: keywords, }
  upto:             /// \.\. ///
  cellkey:          /// \*[-+]?[0-9]+ | [-+]?[A-Z]+\* | [-+]?[A-Z]+[-+]?[0-9]+ | \* ///
  float:            { match: /// [-+]? (?: 0 | [1-9][0-9]* ) \.[0-9]+ ///, value: ( ( s ) -> parseFloat s     ) }
  integer:          { match: /// [-+]? (?: 0 | [1-9][0-9]* ) ///,          value: ( ( s ) -> parseInt   s, 10 ) }
  # star:             /// \* ///
  upto:             '..'
  comma:            ','
  colon:            ':'
  cheat:            '!cheat'
  comment:          /// \# [\x20\t]+ .*? (?: \n | $ ) ///
  semicolon:        /// \s* ; \s* ///
  ws:               { match: /// [ \x20 \t \n ]+ ///, lineBreaks: true }
  # lws:              /// [ \x20 \t ]+ ///
  nl:               { match: /// \n ///, lineBreaks: true }

@lexer = MOO.compile syntax

