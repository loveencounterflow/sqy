# Generated automatically by nearley, version 2.15.1
# http://github.com/Hardmath123/nearley
do ->
  id = (d) -> d[0]

  grammar = {
    Lexer: undefined,
    ParserRules: [
          {"name": "expression$subexpression$1", "symbols": ["term"]},
          {"name": "expression$subexpression$1", "symbols": ["component"]},
          {"name": "expression", "symbols": ["expression$subexpression$1"], "postprocess": id},
          {"name": "term$subexpression$1", "symbols": ["binary_term"]},
          {"name": "term$subexpression$1", "symbols": ["trinary_term"]},
          {"name": "term", "symbols": ["term$subexpression$1"], "postprocess": id},
          {"name": "binary_term$subexpression$1", "symbols": ["binary_operator", "expression", "expression"]},
          {"name": "binary_term", "symbols": ["binary_term$subexpression$1"], "postprocess": id},
          {"name": "trinary_term$subexpression$1", "symbols": ["trinary_operator", "expression", "expression", "expression"]},
          {"name": "trinary_term", "symbols": ["trinary_term$subexpression$1"], "postprocess": id},
          {"name": "component", "symbols": [/./], "postprocess": 
              ( data, loc, reject ) ->
                [ chr, ] = data
                console.log '33821', ( require 'util' ).inspect data
                return reject if /^\s+$/.test chr
                return reject if /^[⿰⿱⿴⿵⿶⿷⿸⿹⿺⿻⿲⿳]$/.test chr
                return chr
              # [\x00-\x20\U{00a0}\U{1680}\U{180e}\U{2000}-\U{200b}\U{202f}\U{205f}\U{3000}\U{feff}]
              #  ( d, loc, reject ) -> throw new Error "#{( require 'util' ).inspect d} at #{( require 'util' ).inspect loc}"
               },
          {"name": "binary_operator$subexpression$1", "symbols": ["leftright"]},
          {"name": "binary_operator$subexpression$1", "symbols": ["topdown"]},
          {"name": "binary_operator$subexpression$1", "symbols": ["surround"]},
          {"name": "binary_operator$subexpression$1", "symbols": ["cap"]},
          {"name": "binary_operator$subexpression$1", "symbols": ["cup"]},
          {"name": "binary_operator$subexpression$1", "symbols": ["leftembrace"]},
          {"name": "binary_operator$subexpression$1", "symbols": ["topleft"]},
          {"name": "binary_operator$subexpression$1", "symbols": ["topright"]},
          {"name": "binary_operator$subexpression$1", "symbols": ["leftbottom"]},
          {"name": "binary_operator$subexpression$1", "symbols": ["interlace"]},
          {"name": "binary_operator", "symbols": ["binary_operator$subexpression$1"], "postprocess": id},
          {"name": "trinary_operator$subexpression$1", "symbols": ["pillars"]},
          {"name": "trinary_operator$subexpression$1", "symbols": ["layers"]},
          {"name": "trinary_operator", "symbols": ["trinary_operator$subexpression$1"], "postprocess": id},
          {"name": "leftright", "symbols": [{"literal":"⿰"}], "postprocess": id},
          {"name": "topdown", "symbols": [{"literal":"⿱"}], "postprocess": id},
          {"name": "surround", "symbols": [{"literal":"⿴"}], "postprocess": id},
          {"name": "cap", "symbols": [{"literal":"⿵"}], "postprocess": id},
          {"name": "cup", "symbols": [{"literal":"⿶"}], "postprocess": id},
          {"name": "leftembrace", "symbols": [{"literal":"⿷"}], "postprocess": id},
          {"name": "topleft", "symbols": [{"literal":"⿸"}], "postprocess": id},
          {"name": "topright", "symbols": [{"literal":"⿹"}], "postprocess": id},
          {"name": "leftbottom", "symbols": [{"literal":"⿺"}], "postprocess": id},
          {"name": "interlace", "symbols": [{"literal":"⿻"}], "postprocess": id},
          {"name": "pillars", "symbols": [{"literal":"⿲"}], "postprocess": id},
          {"name": "layers", "symbols": [{"literal":"⿳"}], "postprocess": id}
      ],
    ParserStart: "expression"
  }
  if typeof module != 'undefined' && typeof module.exports != 'undefined'
    module.exports = grammar;
  else
    window.grammar = grammar;
