
@preprocessor coffee @ {%

'use strict'

############################################################################################################
CND                       = require 'cnd'
rpr                       = CND.rpr
badge                     = 'SQY/GRAMMAR'
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
{ lexer, }                = require './sqy-lexer'

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

# #-----------------------------------------------------------------------------------------------------------
# show = ( ref, d ) ->
#   for token, idx in d
#     log ( CND.grey ref ), ( CND.white idx ), ( CND.yellow jr token )
#   return null

#-----------------------------------------------------------------------------------------------------------
show = ( d, level = 0 ) ->
  indentation = '  '.repeat level
  for x in d
    continue if x is null
    if CND.isa_list x
      show x, level + 1
      continue
    switch x.type
      when x.value  then  info indentation, CND.red jr x.type
      when 'id'     then  info indentation, CND.lime x.id
      else                info indentation, x.type, rpr x.value
  return null

#-----------------------------------------------------------------------------------------------------------
Σ             = ( key             ) -> ( -> Symbol.for key )
$ignore       =                     -> null
join          = ( x, joiner = ''  ) -> x.join joiner
get_loc       = ( token           ) -> "#{token.line}##{token.col}"
$first        = ( x               ) -> x[ 0 ]
$first_value  = ( type            ) -> ( d ) -> { type, value: d[ 0 ].value }
$last         = ( x               ) -> x[ x.length - 1 ]


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
  # selector  = { type: 'star', } if selector.type is 'star'
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
$set_grid = ( d ) ->
  [ SET, GRID, TO, cellkey, ] = filtered d
  loc       = get_loc SET
  type      = 'set_grid'
  size      = cellkey
  { type, size, loc, }

#-----------------------------------------------------------------------------------------------------------
$set_ctx_border = ( d ) ->
  [ SET, edges, BORDER, TO, style, ] = filtered d
  loc       = get_loc SET
  type      = 'set_ctx_border'
  style     = style.value
  edges     = ( edge.value for edge in edges )
  { type, edges, style, loc, }

#-----------------------------------------------------------------------------------------------------------
$set_sel_border = ( d ) ->
  [ SET, edges, BORDER, OF, selectors, TO, style, ] = filtered d
  loc       = get_loc SET
  type      = 'set_sel_border'
  style     = style.value
  edges     = ( edge.value for edge in edges )
  { type, edges, selectors, style, loc, }

#-----------------------------------------------------------------------------------------------------------
$assignment = ( d ) ->
  [ SET, vname, TO, value, ] = filtered d
  type = switch value.type
    when 'sq_string', 'dq_string' then 'text'
    when 'float',     'integer'   then 'number'
    else value.type
  rhs       = { type, value: value.value, }
  loc       = get_loc SET
  type      = 'assignment'
  id        = vname.value
  { type, id, rhs, loc, }

#-----------------------------------------------------------------------------------------------------------
$set_debug = ( d ) ->
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

$_show = ( ref ) -> ( x ) -> debug '44431', x

$filter_flatten = ( d ) -> filtered flatten d, 2

$only_one = ( d ) ->
  throw new Error "µ44909 detected ambiguous grammar #{rpr d}" unless d.length is 1
  return d[ 0 ]

###======================================================================================================###
%}

#-----------------------------------------------------------------------------------------------------------
@lexer lexer

#-----------------------------------------------------------------------------------------------------------
source                -> _ phrase source                                                    {% $filter_flatten       %}
source                -> _ phrase                                                           {% $last                 %}
#-----------------------------------------------------------------------------------------------------------
phrase                -> create                                                             {% $only_one             %}
phrase                -> set                                                                {% $only_one             %}
phrase                -> select                                                             {% $only_one             %}
#...........................................................................................................
create                -> create_field                                                       {% $first                %}
create                -> create_layout                                                      {% $first                %}
#...........................................................................................................
create_field          -> create_named_field                                                 {% $first                %}
create_field          -> create_unnamed_field                                               {% $first                %}
create_named_field    -> "create" __ "field" __ id  __ "at" __ cell_selector s              {% $create_named_field   %}
create_unnamed_field  -> "create" __ "field" __        "at" __ cell_selector s              {% $create_unnamed_field %}
create_layout         -> create_named_layout                                                {% $first                %}
create_named_layout   -> "create" __ "layout" __ id  s                                      {% $create_layout        %}
#...........................................................................................................
set                   -> set_grid                                                           {% $first                %}
set                   -> set_debug                                                          {% $first                %}
set                   -> assignment                                                         {% $first                %}
set                   -> set_ctx_border                                                     {% $first                %}
set                   -> set_sel_border                                                     {% $first                %}
#...........................................................................................................
set_grid              -> "set" __ "grid"  __ "to" __ gridsize  s                            {% $set_grid             %}
set_debug             -> "set" __ "debug" __ "to" __ %boolean s                             {% $set_debug            %}
set_ctx_border        -> "set" __ edges __ border_s __ "to" __ style s                      {% $set_ctx_border       %}
set_sel_border        -> "set" __ edges __ border_s __ "of" __ selectors __ "to" __ style s {% $set_sel_border       %}
assignment            -> "set" __ %vname  __ "to" __ value s                                {% $assignment           %}
value                 -> string                                                             {% $first                %}
value                 -> number                                                             {% $first                %}
value                 -> %boolean                                                           {% $first                %}
string                -> %dq_string                                                         {% $first                %}
string                -> %sq_string                                                         {% $first                %}
number                -> %integer                                                           {% $first                %}
number                -> %float                                                             {% $first                %}
style                 -> string                                                             {% $first                %}
#...........................................................................................................
border_s              -> "border"                                                           {% $first                %}
border_s              -> "borders"                                                          {% $first                %}
edges                 -> edge_comma:+ edge                                                  {% $flatten              %}
edges                 -> edge
edge_comma            -> edge _ %comma _                                                    {% $first                %}
edge                  -> %edge                                                              {% $first_value 'edge'   %}
#...........................................................................................................
select                -> select_fields                                                      {% $first                %}
select_fields         -> "select" __ "fields" __ selectors s                                {% $select_fields        %}
selectors             -> selector_comma:+ selector                                          {% $flatten              %}
selectors             -> selector                                                           {% $flatten              %}
selector_comma        -> selector _ %comma _                                                {% $first                %}
selector              -> abstract_selector                                                  {% $first                %}
selector              -> cell_selector                                                      {% $first                %}
abstract_selector     -> id                                                                 {% $first                %}
cell_selector         -> cellkey                                                            {% $first                %}
cell_selector         -> rangekey                                                           {% $first                %}
rangekey              -> cellkey %upto cellkey                                              {% $rangekey             %}
cellkey               -> %cellkey                                                           {% $cellkey              %}
#...........................................................................................................
clasz                 -> "." [a-z_]:+                                                       {% $clasz                %}
s                     -> %semicolon                                                         {% $first                %}
gridsize              -> cellkey                                                            {% $first                %}
id                    -> %id                                                                {% $id                   %}
#...........................................................................................................
__                    -> %ws:+                                                              {% $ignore               %}
_                     -> %ws:*                                                              {% $ignore               %}


@{% ### ====================================================================================================
nearleyc sqy.ne -o sqy.coffee && coffee -c sqy.coffee && nearley-test -q -i 'create field;' sqy.js
nearley-railroad sqy.ne -o sqy.html
nearley-unparse -n 10 sqy.js

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








