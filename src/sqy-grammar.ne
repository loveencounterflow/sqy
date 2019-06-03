
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
$filter_flatten = ( d ) -> filtered flatten d, 2

#-----------------------------------------------------------------------------------------------------------
$only_one = ( d ) ->
  throw new Error "µ44909 detected ambiguous grammar #{rpr d}" unless d.length is 1
  return d[ 0 ]

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
  { type, id, }

#-----------------------------------------------------------------------------------------------------------
$id = ( d ) ->
  type    = 'id'
  id      = d[ 0 ].value
  { type, id, }

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

#-----------------------------------------------------------------------------------------------------------
$set_ctx_alignment = ( d ) ->
  # debug 'set_ctx_alignment'
  # show d
  [ SET, ALIGN, TO, alignment, ] = filtered d
  loc       = get_loc SET
  direction = if ALIGN.type is 'halign' then 'horizontal' else 'vertical'
  type      = 'set_ctx_alignment'
  align     = alignment.value
  return { type, direction, align, loc, }

#-----------------------------------------------------------------------------------------------------------
$set_sel_alignment = ( d ) ->
  # debug 'set_sel_alignment'
  # show d
  # debug filtered d
  [ SET, ALIGN, OF, selectors, TO, alignment, ] = filtered d
  loc       = get_loc SET
  if CND.isa_list ALIGN then  direction = ALIGN[ 0 ].type
  else                        direction = if ALIGN.type is 'halign' then 'horizontal' else 'vertical'
  type      = 'set_sel_alignment'
  align     = alignment.value
  return { type, selectors, direction, align, loc, }

#-----------------------------------------------------------------------------------------------------------
$set_sel_background = ( d ) ->
  # debug 'set_sel_background'
  # show d
  # debug filtered d
  [ SET, BACKGROUND, OF, selectors, TO, style, ] = filtered d
  loc       = get_loc SET
  type      = 'set_sel_background'
  style     = style.value
  return { type, selectors, style, loc, }

#-----------------------------------------------------------------------------------------------------------
$set_unit_lengths = ( d ) ->
  # debug 'set_sel_alignment'
  # show d
  switch ( d = filtered d ).length
    when 4
      [ SET,            UNIT, TO, quantity, ] = filtered d
      direction = 'both'
    when 5
      [ SET, direction, UNIT, TO, quantity, ] = filtered d
      direction = direction.value
  #.........................................................................................................
  if CND.isa_list quantity then [ value, unit, ] = quantity
  else                          [ value, unit, ] = [ 1, quantity, ]
  type      = 'set_unit_lengths'
  value     = if CND.isa_number value then value else value.value
  unit      = unit.value
  loc       = get_loc SET
  return { type, direction, value, unit, }

#-----------------------------------------------------------------------------------------------------------
$set_lane_sizes = ( d ) ->
  # debug 'set_sel_alignment'
  # debug filtered d
  # show d
  [ SET, lane, direction, TO, value, ] = filtered d
  type      = 'set_lane_sizes'
  loc       = get_loc SET
  lane      = lane.value
  lane      = 'col' if lane is 'column'
  direction = direction.value
  direction = 'width'   if direction is 'widths'
  direction = 'height'  if direction is 'heights'
  value     = value.value
  return { type, lane, direction, value, }

#-----------------------------------------------------------------------------------------------------------
$set_default_gaps = ( d ) ->
  [ SET, DEFAULT, feature, GAPS, TO, value, ] = filtered d
  type      = 'set_default_gaps'
  feature   = feature.value
  value     = value.value
  return { type, feature, value, }

#-----------------------------------------------------------------------------------------------------------
$set_field_gaps = ( d ) ->
  # debug 'set_field_gaps'
  # debug filtered d
  # show d
  [ SET, edges, feature, GAPS, OF, selectors, TO, value, ] = filtered d
  type      = 'set_field_gaps'
  feature   = feature.value
  value     = value.value
  edges     = ( edge.value for edge in edges )
  return { type, edges, feature, selectors, value, }


###======================================================================================================###
%}

#-----------------------------------------------------------------------------------------------------------
@lexer lexer

#-----------------------------------------------------------------------------------------------------------
source                -> _ phrase source                                                    {% $filter_flatten       %}
source                -> _ phrase                                                           {% $last                 %}
source                -> _ comment                                                         {% $filter_flatten       %}
#-----------------------------------------------------------------------------------------------------------
comment               -> _ %comment                                                         {% $ignore              %}
#-----------------------------------------------------------------------------------------------------------
phrase                -> create                                                             {% $only_one             %}
phrase                -> set                                                                {% $only_one             %}
# phrase                -> select                                                             {% $only_one             %}
phrase                -> cheat                                                              {% $last                 %}
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
set                   -> set_unit_lengths                                                   {% $first                %}
set                   -> set_col_widths                                                     {% $first                %}
set                   -> set_row_heights                                                    {% $first                %}
set                   -> assignment                                                         {% $first                %}
# set                   -> set_ctx_border                                                     {% $first                %}
set                   -> set_sel_border                                                     {% $first                %}
# set                   -> set_ctx_alignment                                                  {% $first                %}
set                   -> set_sel_alignment                                                  {% $first                %}
set                   -> set_default_gaps                                                   {% $first                %}
set                   -> set_field_gaps                                                     {% $first                %}
#...........................................................................................................
set_grid              -> "set" __ "grid"  __ "to" __ gridsize  s                            {% $set_grid             %}
set_debug             -> "set" __ "debug" __ "to" __ %boolean s                             {% $set_debug            %}
set_unit_lengths      -> "set" __ "unit" __ "to" __ unit s                                  {% $set_unit_lengths     %}
set_unit_lengths      -> "set" __ "horizontal" __ "unit" __ "to" __ unit s                  {% $set_unit_lengths     %}
set_unit_lengths      -> "set" __ "vertical"   __ "unit" __ "to" __ unit s                  {% $set_unit_lengths     %}
set_col_widths        -> "set" __ column __ width_s __ "to" __ number s                     {% $set_lane_sizes       %}
set_row_heights       -> "set" __ "row" __ height_s __ "to" __ number s                     {% $set_lane_sizes       %}
# set_ctx_border        -> "set" __ edges __ border_s __ "to" __ style s                      {% $set_ctx_border       %}
set_sel_border        -> "set" __ edges __ border_s __ "of" __ selectors __ "to" __ style s {% $set_sel_border       %}
# set_ctx_alignment     -> "set" __ halign __ "to" __                      halignment s       {% $set_ctx_alignment    %}
# set_ctx_alignment     -> "set" __ valign __ "to" __                      valignment s       {% $set_ctx_alignment    %}
set_sel_alignment     -> "set" __ halign __ "of" __ selectors __ "to" __ halignment s       {% $set_sel_alignment    %}
set_sel_alignment     -> "set" __ valign __ "of" __ selectors __ "to" __ valignment s       {% $set_sel_alignment    %}
set_sel_alignment     -> "set" __ %background __ "of" __ selectors __ "to" __ style s       {% $set_sel_background    %}
set_default_gaps      -> "set" __ "default" __ feature __ gap_s __                      "to" __ number s         {% $set_default_gaps     %}
set_field_gaps        -> "set" __ edges     __ feature __ gap_s __ "of" __ selectors __ "to" __ number s         {% $set_field_gaps       %}
assignment            -> "set" __ %vname  __ "to" __ value s                                {% $assignment           %}
#...........................................................................................................
cheat                 -> %cheat s                                                           {% -> { type: 'cheat', }                %}
#...........................................................................................................
feature               -> "border"                                                           {% $first                %}
feature               -> "text"                                                             {% $first                %}
feature               -> "background"                                                       {% $first                %}
unit                  -> %name                                                              {% $first                %}
unit                  -> number %name                                                       {% $flatten              %}
value                 -> string                                                             {% $first                %}
value                 -> number                                                             {% $first                %}
value                 -> %boolean                                                           {% $first                %}
string                -> %dq_string                                                         {% $first                %}
string                -> %sq_string                                                         {% $first                %}
number                -> %integer                                                           {% $first                %}
number                -> %float                                                             {% $first                %}
style                 -> string                                                             {% $first                %}
halign                -> "halign"                                                           {% $first                %}
halign                -> "horizontal" __ "alignment"                                        {% $flatten              %}
valign                -> "valign"                                                           {% $first                %}
valign                -> "vertical" __ "alignment"                                          {% $flatten              %}
#...........................................................................................................
border_s              -> "border"                                                           {% $first                %}
border_s              -> "borders"                                                          {% $first                %}
gap_s                 -> "gap"                                                              {% $first                %}
gap_s                 -> "gaps"                                                             {% $first                %}
edges                 -> edge_comma:+ edge                                                  {% $flatten              %}
edges                 -> edge
edge_comma            -> edge _ %comma _                                                    {% $first                %}
edge                  -> "top"                                                              {% $first_value 'edge'         %}
edge                  -> "left"                                                             {% $first_value 'edge'         %}
column                -> "col"                                                              {% $first_value 'lane'         %}
column                -> "column"                                                           {% $first_value 'lane'         %}
width_s               -> "width"                                                            {% $first_value 'direction'    %}
width_s               -> "widths"                                                           {% $first_value 'direction'    %}
height_s              -> "height"                                                           {% $first_value 'direction'    %}
height_s              -> "heights"                                                          {% $first_value 'direction'    %}
edge                  -> "bottom"                                                           {% $first_value 'edge'         %}
edge                  -> "right"                                                            {% $first_value 'edge'         %}
edge                  -> "all"                                                              {% $first_value 'edge'         %}
halignment            -> "left"                                                             {% $first_value 'halignment'   %}
halignment            -> "right"                                                            {% $first_value 'halignment'   %}
halignment            -> "center"                                                           {% $first_value 'halignment'   %}
halignment            -> "justified"                                                        {% $first_value 'halignment'   %}
valignment            -> "top"                                                              {% $first_value 'valignment'   %}
valignment            -> "bottom"                                                           {% $first_value 'valignment'   %}
valignment            -> "center"                                                           {% $first_value 'valignment'   %}
#...........................................................................................................
# select                -> select_fields                                                      {% $first                %}
# select_fields         -> "select" __ "fields" __ selectors s                                {% $select_fields        %}
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

set col[umn]  width[s]  of * to 10;
set row       height[s] of * to 10;

cheat!; # a temporary allowance

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








