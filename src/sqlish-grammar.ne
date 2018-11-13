
@preprocessor coffee @ {%

'use strict'

############################################################################################################
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'SQLISH/GRAMMAR'
log                       = CND.get_logger 'plain',     badge
info                      = CND.get_logger 'info',      badge
whisper                   = CND.get_logger 'whisper',   badge
alert                     = CND.get_logger 'alert',     badge
debug                     = CND.get_logger 'debug',     badge
warn                      = CND.get_logger 'warn',      badge
help                      = CND.get_logger 'help',      badge
urge                      = CND.get_logger 'urge',      badge
echo                      = CND.echo.bind CND

###======================================================================================================###
{ lexer, }                = ( require './sqlish-lexer' )

#-----------------------------------------------------------------------------------------------------------
log = ( P... ) -> console.log P...
jr  = JSON.stringify

#-----------------------------------------------------------------------------------------------------------
flatten = ( d, n = 1 ) ->
  return d if n < 1
  return ( if n is 1 then d else flatten d, n - 1 ).reduce ( ( a, b ) -> a.concat b ), []

#-----------------------------------------------------------------------------------------------------------
$flatten = ( d, n = 1 ) -> flatten d, n

#-----------------------------------------------------------------------------------------------------------
$filter  = ( d ) -> d.filter ( x ) -> x isnt null

#-----------------------------------------------------------------------------------------------------------
filter = ( d ) ->
  for x in d
    continue if x is null
    continue if x is Symbol.for 'LWS'
    continue if x is Symbol.for 'STOP'
    continue if x.type is 'semicolon'
    yield x
  yield return

#-----------------------------------------------------------------------------------------------------------
filtered = ( d ) -> [ ( filter d )..., ]

#-----------------------------------------------------------------------------------------------------------
enumerate = ( iterator ) ->
  idx = 0
  yield [ x, ( idx++ ), ] for x from iterator

#-----------------------------------------------------------------------------------------------------------
show = ( ref, d ) ->
  for token, idx in d
    log ( CND.grey ref ), ( CND.white idx ), ( CND.yellow jr token )
  return null

#-----------------------------------------------------------------------------------------------------------
Σ             = ( key             ) -> ( -> Symbol.for key )
$ignore       =                     -> null
join          = ( x, joiner = ''  ) -> x.join joiner
get_loc       = ( token           ) -> "#{token.line}##{token.col}"
$first        = ( x               ) -> x[ 0 ]
$first_value  = ( type            ) -> ( d ) -> { type, value: d[ 0 ].value }

#-----------------------------------------------------------------------------------------------------------
$clasz = ( d ) ->
  type    = 'clasz'
  id      = d[ 0 ].value
  { type: 'clasz', id, }

#-----------------------------------------------------------------------------------------------------------
$id = ( d ) ->
  type    = 'id'
  id      = d[ 0 ].value
  { type: 'id', id, }

#-----------------------------------------------------------------------------------------------------------
$cellkey = ( d ) ->
  type    = 'cellkey'
  value   = d[ 0 ].value
  { type, value, }

#-----------------------------------------------------------------------------------------------------------
$rangekey = ( d ) ->
  # debug '$rangekey', d
  type                      = 'rangekey'
  [ first, UPTO, second, ]  = d
  { type, first, second, }

#-----------------------------------------------------------------------------------------------------------
_create_field = ( first, selector, id ) ->
  loc       = get_loc first
  type      = 'create_field'
  selector  = { type: 'star', } if selector.type is 'star'
  id        = id?.id ? null
  { type, id, selector, loc, }

#-----------------------------------------------------------------------------------------------------------
$create_named_field = ( d ) ->
  [ CREATE, FIELD, id, AT, selector, ] = filtered d
  return _create_field CREATE, selector, id

#-----------------------------------------------------------------------------------------------------------
$create_unnamed_field = ( d ) ->
  [ CREATE, FIELD, AT, selector, ] = filtered d
  return _create_field CREATE, selector, null

#-----------------------------------------------------------------------------------------------------------
$create_layout = ( d ) ->
  [ CREATE, LAYOUT, id, ] = filtered d
  loc       = get_loc CREATE
  type      = 'create_layout'
  id        = id.id
  { type, id, loc, }

#-----------------------------------------------------------------------------------------------------------
$set_grid = ( d, loc ) ->
  [ SET, GRID, TO, cellkey, ] = filtered d
  loc       = get_loc SET
  type      = 'set_grid'
  size      = cellkey
  { type, size, loc, }

#-----------------------------------------------------------------------------------------------------------
$set_vname = ( d, loc ) ->
  [ SET, vname, TO, value, ] = filtered d
  loc       = get_loc SET
  type      = 'set_vname'
  id        = vname.value
  value     = value.value
  { type, id, value, loc, }

#-----------------------------------------------------------------------------------------------------------
$set_debug = ( d, loc ) ->
  [ SET, DEBUG, TO, toggle, ] = filtered d
  loc       = get_loc SET
  type      = 'set_debug'
  value     = toggle.value
  { type, value, loc, }

#-----------------------------------------------------------------------------------------------------------
$select_fields = ( d ) ->
  [ SELECT, FIELDS, selectors, ] = filtered d
  loc       = get_loc SELECT
  type      = 'select_fields'
  return { type, selectors, loc, }



###======================================================================================================###
%}

#-----------------------------------------------------------------------------------------------------------
@lexer lexer

#-----------------------------------------------------------------------------------------------------------
phrase                -> create                                                     {% $first                %}
phrase                -> set                                                        {% $first                %}
phrase                -> select                                                     {% $first                %}
#...........................................................................................................
create                -> create_field                                               {% $first                %}
create                -> create_layout                                              {% $first                %}
#...........................................................................................................
create_field          -> create_named_field                                         {% $first                %}
create_field          -> create_unnamed_field                                       {% $first                %}
create_named_field    -> "create" __ "field" __ id  __ "at" __ cell_selector _ stop {% $create_named_field   %}
create_unnamed_field  -> "create" __ "field" __        "at" __ cell_selector _ stop {% $create_unnamed_field %}
create_layout         -> create_named_layout                                        {% $first                %}
create_named_layout   -> "create" __ "layout" __ id  _ stop                         {% $create_layout        %}
#...........................................................................................................
set                   -> set_grid                                                   {% $first                %}
set                   -> set_debug                                                  {% $first                %}
set                   -> set_vname                                                  {% $first                %}
#...........................................................................................................
set_grid              -> "set" __ "grid"  __ "to" __ gridsize  _ stop               {% $set_grid             %}
set_debug             -> "set" __ "debug" __ "to" __ %boolean _ stop                {% $set_debug            %}
set_vname             -> "set" __ %vname  __ "to" __ value _ stop                   {% $set_vname            %}
value                 -> string                                                    {% $first                %}
value                 -> number                                                    {% $first                %}
value                 -> %boolean                                                   {% $first                %}
string                -> %dq_string {% $first                %}
string                -> %sq_string {% $first                %}
number                -> %integer       {% $first                %}
number                -> %float       {% $first                %}
#...........................................................................................................
clasz                 -> "." [a-z_]:+                                               {% $clasz                %}
stop                  -> %semicolon                                                 {% $first                %}
gridsize              -> cellkey                                                    {% $first                %}
id                    -> %id                                                        {% $id                   %}
#...........................................................................................................
select                -> select_fields                                              {% $first                %}
select_fields         -> "select" __ "fields" __ selectors _ stop                   {% $select_fields        %}
selectors             -> selector_comma:+ selector                                  {% $flatten              %}
selectors             -> selector                                                   {% $flatten              %}
selector_comma        -> selector _ %comma _                                            {% $first                %}
selector              -> abstract_selector                                          {% $first                %}
selector              -> cell_selector                                              {% $first                %}
abstract_selector     -> id                                                         {% $first                %}
cell_selector         -> cellkey                                                   {% $first                %}
cell_selector         -> rangekey                                                   {% $first                %}
rangekey              -> cellkey %upto cellkey                                      {% $rangekey             %}
cellkey               -> %cellkey                                                   {% $cellkey                %}
#...........................................................................................................
__                    -> " ":+                                                      {% Σ 'LWS'               %}
_                     -> " ":*                                                      {% Σ 'LWS'               %}


@{% ### ====================================================================================================
nearleyc sqlish.ne -o sqlish.coffee && coffee -c sqlish.coffee && nearley-test -q -i 'create field;' sqlish.js
nearley-railroad sqlish.ne -o sqlish.html
nearley-unparse -n 10 sqlish.js

create layout #mylayout;
set grid to G5;
set debug to false;
create field at A1;
create field at A1..B2;
create field #myfield at A1..B2;
select fields #myfield:                       set top border to 'thin, blue';
select fields #myfield, #thatone, .h, A1..B2: set top border to 'thin, blue';
select fields .caption:                       set horizontal alignment to left;

# in layout #mylayout, create field at A1;
# in layout #mylayout, create field at A1..B2;
# in layout #mylayout, create field at A1, at B2, #anotherfield at C3..D5;
# in layout #mylayout, create field #myfield at A1..B2;
# select layout #mylayout, then create: field  #myfield at A1, field at B1, field #another at C3;
# select layout #mylayout, then create  field: #myfield at A1,       at B1,       #another at C3;
# create layout: #this, #that;
# create: layout #this, layout #that;
# create layout #mylayout, then: create field  #caption.h at A1..D1, create field .text at: A2, B2, C2, D2;
# create layout #mylayout, then create: field  #caption.h at A1..D1,        field .text at: A2, B2, C2, D2;
# create layout #mylayout, then create  field: #caption.h at A1..D1,              .text at: A2, B2, C2, D2;

### %}








