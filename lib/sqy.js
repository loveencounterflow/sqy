// Generated by CoffeeScript 2.3.1
(function() {
  'use strict';
  var CND, NEARLEY, alert, badge, debug, echo, help, info, log, rpr, urge, warn, whisper;

  //###########################################################################################################
  CND = require('cnd');

  rpr = CND.rpr;

  badge = 'SQY';

  log = CND.get_logger('plain', badge);

  info = CND.get_logger('info', badge);

  whisper = CND.get_logger('whisper', badge);

  alert = CND.get_logger('alert', badge);

  debug = CND.get_logger('debug', badge);

  warn = CND.get_logger('warn', badge);

  help = CND.get_logger('help', badge);

  urge = CND.get_logger('urge', badge);

  echo = CND.echo.bind(CND);

  NEARLEY = require('nearley');

  //-----------------------------------------------------------------------------------------------------------
  this.lexer = (require('./sqy-lexer')).lexer;

  this.grammar = require('./sqy-grammar');

  //-----------------------------------------------------------------------------------------------------------
  this.parse = function(source) {
    var R, parser;
    parser = new NEARLEY.Parser(NEARLEY.Grammar.fromCompiled(this.grammar));
    parser.feed(source);
    R = parser.results;
    if (R.length !== 1) {
      throw new Error(`µ55891 detected ambiguous grammar ${rpr(R)}`);
    }
    return R[0];
  };

}).call(this);

//# sourceMappingURL=sqy.js.map