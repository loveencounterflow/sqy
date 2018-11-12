
@preprocessor coffee

@ {%
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
filter  = ( d ) -> d.filter ( x ) -> x isnt null
Σ       = ( key ) -> ( -> Symbol.for key )
$ignore = -> null
join    = ( x, joiner = '' ) -> x.join joiner

#-----------------------------------------------------------------------------------------------------------
$float              = ( d, loc ) -> { type: 'float',      value: "#{d[ 0 ].join ''}.#{d[ 2 ].join ''}", loc, }
$integer            = ( d, loc ) -> { type: 'integer',    value: ( d[ 0 ].join '' ),                    loc, }

#-----------------------------------------------------------------------------------------------------------
$name = ( d, loc ) ->
  type                        = 'id'
  id                          = join flatten d
  { type: 'id', id, loc, }

#-----------------------------------------------------------------------------------------------------------
$cellkey = ( d, loc ) ->
  type                        = 'cellkey'
  [ colletters, rowdigits, ]  = flatten d, 1
  colletters                  = join colletters
  rowdigits                   = join rowdigits
  { type, colletters, rowdigits, loc, }

#-----------------------------------------------------------------------------------------------------------
$rangekey = ( d, loc ) ->
  type                  = 'rangekey'
  [ first, _, second, ] = d
  { type, first, second, loc, }

#-----------------------------------------------------------------------------------------------------------
$create_field = ( d, loc ) ->
  [ CREATE, _, FIELD, _, identifier, _, AT, _, selector, _, STOP, ] = d
  type      = 'create_field'
  id        = if identifier?.type is 'id' then identifier.id else null
  { type, id, selector, loc, }

#-----------------------------------------------------------------------------------------------------------
$create_layout = ( d, loc ) ->
  [ CREATE, _, LAYOUT, _, identifier, _, STOP, ]  = d
  type  = 'create_layout'
  id    = if identifier?.type is 'id' then identifier.id else null
  { type, id, loc, }

#-----------------------------------------------------------------------------------------------------------
$set_grid = ( d, loc ) ->
  [ SET, _, GRID, _, TO, _, cellkey, _, STOP, ]  = d
  type  = 'set_grid'
  size  = cellkey
  { type, size, loc, }

#-----------------------------------------------------------------------------------------------------------
$boolean = ( d, loc ) ->
  log '23133', d
  type  = 'boolean'
  { type, loc, }

#-----------------------------------------------------------------------------------------------------------
$set_debug = ( d, loc ) ->
  [ SET, _, DEBUG, _, TO, _, toggle, _, STOP, ]  = d
  # log '23774', d
  # log '23774', toggle
  type  = 'set_debug'
  { type, toggle, loc, }


###======================================================================================================###
%}

#-----------------------------------------------------------------------------------------------------------
phrase                -> create                                             {% id                 %}
phrase                -> set                                                {% id                 %}
#...........................................................................................................
create                -> create_field                                       {% id                 %}
create                -> create_layout                                      {% id                 %}
#...........................................................................................................
create_field          -> create_named_field                                 {% id                 %}
create_field          -> create_unnamed_field                               {% id                 %}
create_named_field    -> CREATE __ FIELD __ id __ "at" __ selector _ STOP   {% $create_field      %}
create_unnamed_field  -> CREATE __ FIELD __       "at" __ selector _ STOP   {% $create_field      %}
create_layout         -> create_named_layout                                {% id                 %}
create_named_layout   -> CREATE __ LAYOUT __ id _ STOP                      {% $create_layout     %}
#...........................................................................................................
set                   -> set_grid                                           {% id                 %}
set                   -> set_debug                                          {% id                 %}
#...........................................................................................................
set_grid              -> SET __ GRID __   TO __ cellkey _ STOP              {% $set_grid          %}
set_debug             -> SET __ DEBUG __  TO __ boolean _ STOP              {% $set_debug         %}
#...........................................................................................................
id                    -> "#" [a-z_]:+                                       {% $name              %}
clasz                 -> "." [a-z_]:+                                       {% $name              %}
boolean               -> "true" | "false"                                      # {% $boolean           %}
selector              -> cellkey                                            {% id                 %}
selector              -> rangekey                                           {% id                 %}
cellkey               -> ( [A-Z]:+ | "*" ) ( [0-9]:+ | "*" )                {% $cellkey           %}
rangekey              -> cellkey UPTO cellkey                               {% $rangekey          %}
#...........................................................................................................
__                    -> " ":+                                              {% Σ 'LWS'            %}
_                     -> " ":*                                              {% Σ 'LWS'            %}
STOP                  -> ";"                                                {% Σ 'STOP'           %}
CREATE                -> "create"                                           {% Σ 'CREATE'         %}
LAYOUT                -> "layout"                                           {% Σ 'LAYOUT'         %}
GRID                  -> "grid"                                             {% Σ 'GRID'           %}
DEBUG                 -> "debug"                                            {% Σ 'DEBUG'           %}
SET                   -> "set"                                              {% Σ 'SET'            %}
FIELD                 -> "field"                                            {% Σ 'FIELD'          %}
AT                    -> "at"                                               {% Σ 'AT'             %}
TO                    -> "to"                                               {% Σ 'TO'             %}
UPTO                  -> ".."                                               {% Σ 'UPTO'           %}
# TRUE                  -> "true"                                               {% Σ 'TRUE'           %}
# FALSE                 -> "false"                                            {% Σ 'FALSE'          %}


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








