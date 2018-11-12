# Generated automatically by nearley, version 2.15.1
# http://github.com/Hardmath123/nearley
do ->
  id = (d) -> d[0]

  
  log = ( P... ) -> console.log P...
  
  $expression_plus  = ( d, loc ) -> { type: 'sum',        value: [ d[ 0 ], d[ 2 ], ],                   loc, }
  $expression_minus = ( d, loc ) -> { type: 'difference', value: [ d[ 0 ], d[ 2 ], ],                   loc, }
  $expression_group = ( d, loc ) -> { type: 'group',      value: d[ 1 ],                                loc, }
  $float            = ( d, loc ) -> { type: 'float',      value: "#{d[ 0 ].join ''}.#{d[ 2 ].join ''}", loc, }
  $integer          = ( d, loc ) -> { type: 'integer',    value: ( d[ 0 ].join '' ),                    loc, }
  
  
  grammar = {
    Lexer: undefined,
    ParserRules: [
          {"name": "expression", "symbols": ["number"], "postprocess": id},
          {"name": "expression", "symbols": ["expression", {"literal":"+"}, "a_expression"], "postprocess": $expression_plus},
          {"name": "expression", "symbols": ["expression", {"literal":"-"}, "a_expression"], "postprocess": $expression_minus},
          {"name": "expression", "symbols": ["a_expression"], "postprocess": id},
          {"name": "expression", "symbols": [{"literal":"("}, "expression", {"literal":")"}], "postprocess": $expression_group},
          {"name": "number", "symbols": ["integer"], "postprocess": id},
          {"name": "number", "symbols": ["float"], "postprocess": id},
          {"name": "integer$ebnf$1", "symbols": [/[0-9,]/]},
          {"name": "integer$ebnf$1", "symbols": ["integer$ebnf$1", /[0-9,]/], "postprocess": (d) -> d[0].concat([d[1]])},
          {"name": "integer", "symbols": ["integer$ebnf$1"], "postprocess": $integer},
          {"name": "float$ebnf$1", "symbols": [/[0-9,]/]},
          {"name": "float$ebnf$1", "symbols": ["float$ebnf$1", /[0-9,]/], "postprocess": (d) -> d[0].concat([d[1]])},
          {"name": "float$ebnf$2", "symbols": [/[0-9]/]},
          {"name": "float$ebnf$2", "symbols": ["float$ebnf$2", /[0-9]/], "postprocess": (d) -> d[0].concat([d[1]])},
          {"name": "float", "symbols": ["float$ebnf$1", {"literal":"."}, "float$ebnf$2"], "postprocess": $float}
      ],
    ParserStart: "expression"
  }
  if typeof module != 'undefined' && typeof module.exports != 'undefined'
    module.exports = grammar;
  else
    window.grammar = grammar;
