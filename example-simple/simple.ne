
@preprocessor coffee

@ {%

log = ( P... ) -> console.log P...

$expression_plus  = ( d, loc ) -> { type: 'sum',        value: [ d[ 0 ], d[ 2 ], ],                   loc, }
$expression_minus = ( d, loc ) -> { type: 'difference', value: [ d[ 0 ], d[ 2 ], ],                   loc, }
$expression_group = ( d, loc ) -> { type: 'group',      value: d[ 1 ],                                loc, }
$float            = ( d, loc ) -> { type: 'float',      value: "#{d[ 0 ].join ''}.#{d[ 2 ].join ''}", loc, }
$integer          = ( d, loc ) -> { type: 'integer',    value: ( d[ 0 ].join '' ),                    loc, }

%}

expression  -> number                       {% id                   %}
expression  -> expression  "+"  expression  {% $expression_plus     %}
expression  -> expression  "-"  expression  {% $expression_minus    %}
expression  -> "("  expression  ")"         {% $expression_group    %}
number      -> integer                      {% id                   %}
number      -> float                        {% id                   %}
integer     -> [0-9,]:+                     {% $integer             %}
float       -> [0-9,]:+ "." [0-9]:+         {% $float               %}



