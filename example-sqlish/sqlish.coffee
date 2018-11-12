# Generated automatically by nearley, version 2.15.1
# http://github.com/Hardmath123/nearley
do ->
  id = (d) -> d[0]

  ###======================================================================================================###
  
  
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
  join    = ( x ) -> x.join ''
  
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
  
   ### ====================================================================================================
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
  
  ### 
  grammar = {
    Lexer: undefined,
    ParserRules: [
          {"name": "phrase", "symbols": ["create"], "postprocess": id},
          {"name": "phrase", "symbols": ["set"], "postprocess": id},
          {"name": "create", "symbols": ["create_field"], "postprocess": id},
          {"name": "create", "symbols": ["create_layout"], "postprocess": id},
          {"name": "create_field", "symbols": ["create_named_field"], "postprocess": id},
          {"name": "create_field", "symbols": ["create_unnamed_field"], "postprocess": id},
          {"name": "create_named_field$string$1", "symbols": [{"literal":"a"}, {"literal":"t"}], "postprocess": (d) -> d.join('')},
          {"name": "create_named_field", "symbols": ["CREATE", "__", "FIELD", "__", "id", "__", "create_named_field$string$1", "__", "selector", "_", "STOP"], "postprocess": $create_field},
          {"name": "create_unnamed_field$string$1", "symbols": [{"literal":"a"}, {"literal":"t"}], "postprocess": (d) -> d.join('')},
          {"name": "create_unnamed_field", "symbols": ["CREATE", "__", "FIELD", "__", "create_unnamed_field$string$1", "__", "selector", "_", "STOP"], "postprocess": $create_field},
          {"name": "create_layout", "symbols": ["create_named_layout"], "postprocess": id},
          {"name": "create_named_layout", "symbols": ["CREATE", "__", "LAYOUT", "__", "id", "_", "STOP"], "postprocess": $create_layout},
          {"name": "set", "symbols": ["set_grid"], "postprocess": id},
          {"name": "set", "symbols": ["set_debug"], "postprocess": id},
          {"name": "set_grid", "symbols": ["SET", "__", "GRID", "__", "TO", "__", "cellkey", "_", "STOP"], "postprocess": $set_grid},
          {"name": "set_debug", "symbols": ["SET", "__", "DEBUG", "__", "TO", "__", "boolean", "_", "STOP"], "postprocess": $set_debug},
          {"name": "id$ebnf$1", "symbols": [/[a-z_]/]},
          {"name": "id$ebnf$1", "symbols": ["id$ebnf$1", /[a-z_]/], "postprocess": (d) -> d[0].concat([d[1]])},
          {"name": "id", "symbols": [{"literal":"#"}, "id$ebnf$1"], "postprocess": $name},
          {"name": "clasz$ebnf$1", "symbols": [/[a-z_]/]},
          {"name": "clasz$ebnf$1", "symbols": ["clasz$ebnf$1", /[a-z_]/], "postprocess": (d) -> d[0].concat([d[1]])},
          {"name": "clasz", "symbols": [{"literal":"."}, "clasz$ebnf$1"], "postprocess": $name},
          {"name": "boolean$string$1", "symbols": [{"literal":"t"}, {"literal":"r"}, {"literal":"u"}, {"literal":"e"}], "postprocess": (d) -> d.join('')},
          {"name": "boolean", "symbols": ["boolean$string$1"]},
          {"name": "boolean$string$2", "symbols": [{"literal":"f"}, {"literal":"a"}, {"literal":"l"}, {"literal":"s"}, {"literal":"e"}], "postprocess": (d) -> d.join('')},
          {"name": "boolean", "symbols": ["boolean$string$2"]},
          {"name": "selector", "symbols": ["cellkey"], "postprocess": id},
          {"name": "selector", "symbols": ["rangekey"], "postprocess": id},
          {"name": "cellkey$subexpression$1$ebnf$1", "symbols": [/[A-Z]/]},
          {"name": "cellkey$subexpression$1$ebnf$1", "symbols": ["cellkey$subexpression$1$ebnf$1", /[A-Z]/], "postprocess": (d) -> d[0].concat([d[1]])},
          {"name": "cellkey$subexpression$1", "symbols": ["cellkey$subexpression$1$ebnf$1"]},
          {"name": "cellkey$subexpression$1", "symbols": [{"literal":"*"}]},
          {"name": "cellkey$subexpression$2$ebnf$1", "symbols": [/[0-9]/]},
          {"name": "cellkey$subexpression$2$ebnf$1", "symbols": ["cellkey$subexpression$2$ebnf$1", /[0-9]/], "postprocess": (d) -> d[0].concat([d[1]])},
          {"name": "cellkey$subexpression$2", "symbols": ["cellkey$subexpression$2$ebnf$1"]},
          {"name": "cellkey$subexpression$2", "symbols": [{"literal":"*"}]},
          {"name": "cellkey", "symbols": ["cellkey$subexpression$1", "cellkey$subexpression$2"], "postprocess": $cellkey},
          {"name": "rangekey", "symbols": ["cellkey", "UPTO", "cellkey"], "postprocess": $rangekey},
          {"name": "__$ebnf$1", "symbols": [{"literal":" "}]},
          {"name": "__$ebnf$1", "symbols": ["__$ebnf$1", {"literal":" "}], "postprocess": (d) -> d[0].concat([d[1]])},
          {"name": "__", "symbols": ["__$ebnf$1"], "postprocess": Σ 'LWS'},
          {"name": "_$ebnf$1", "symbols": []},
          {"name": "_$ebnf$1", "symbols": ["_$ebnf$1", {"literal":" "}], "postprocess": (d) -> d[0].concat([d[1]])},
          {"name": "_", "symbols": ["_$ebnf$1"], "postprocess": Σ 'LWS'},
          {"name": "STOP", "symbols": [{"literal":";"}], "postprocess": Σ 'STOP'},
          {"name": "CREATE$string$1", "symbols": [{"literal":"c"}, {"literal":"r"}, {"literal":"e"}, {"literal":"a"}, {"literal":"t"}, {"literal":"e"}], "postprocess": (d) -> d.join('')},
          {"name": "CREATE", "symbols": ["CREATE$string$1"], "postprocess": Σ 'CREATE'},
          {"name": "LAYOUT$string$1", "symbols": [{"literal":"l"}, {"literal":"a"}, {"literal":"y"}, {"literal":"o"}, {"literal":"u"}, {"literal":"t"}], "postprocess": (d) -> d.join('')},
          {"name": "LAYOUT", "symbols": ["LAYOUT$string$1"], "postprocess": Σ 'LAYOUT'},
          {"name": "GRID$string$1", "symbols": [{"literal":"g"}, {"literal":"r"}, {"literal":"i"}, {"literal":"d"}], "postprocess": (d) -> d.join('')},
          {"name": "GRID", "symbols": ["GRID$string$1"], "postprocess": Σ 'GRID'},
          {"name": "DEBUG$string$1", "symbols": [{"literal":"d"}, {"literal":"e"}, {"literal":"b"}, {"literal":"u"}, {"literal":"g"}], "postprocess": (d) -> d.join('')},
          {"name": "DEBUG", "symbols": ["DEBUG$string$1"], "postprocess": Σ 'DEBUG'},
          {"name": "SET$string$1", "symbols": [{"literal":"s"}, {"literal":"e"}, {"literal":"t"}], "postprocess": (d) -> d.join('')},
          {"name": "SET", "symbols": ["SET$string$1"], "postprocess": Σ 'SET'},
          {"name": "FIELD$string$1", "symbols": [{"literal":"f"}, {"literal":"i"}, {"literal":"e"}, {"literal":"l"}, {"literal":"d"}], "postprocess": (d) -> d.join('')},
          {"name": "FIELD", "symbols": ["FIELD$string$1"], "postprocess": Σ 'FIELD'},
          {"name": "AT$string$1", "symbols": [{"literal":"a"}, {"literal":"t"}], "postprocess": (d) -> d.join('')},
          {"name": "AT", "symbols": ["AT$string$1"], "postprocess": Σ 'AT'},
          {"name": "TO$string$1", "symbols": [{"literal":"t"}, {"literal":"o"}], "postprocess": (d) -> d.join('')},
          {"name": "TO", "symbols": ["TO$string$1"], "postprocess": Σ 'TO'},
          {"name": "UPTO$string$1", "symbols": [{"literal":"."}, {"literal":"."}], "postprocess": (d) -> d.join('')},
          {"name": "UPTO", "symbols": ["UPTO$string$1"], "postprocess": Σ 'UPTO'}
      ],
    ParserStart: "phrase"
  }
  if typeof module != 'undefined' && typeof module.exports != 'undefined'
    module.exports = grammar;
  else
    window.grammar = grammar;
