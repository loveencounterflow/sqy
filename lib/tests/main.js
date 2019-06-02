// Generated by CoffeeScript 2.4.1
(function() {
  'use strict';
  var CND, L, alert, badge, debug, echo, help, i, info, len, log, module, name, path, ref, rpr, test, urge, value, warn, whisper;

  //###########################################################################################################
  CND = require('cnd');

  rpr = CND.rpr;

  badge = 'SQY/TESTS/MAIN';

  log = CND.get_logger('plain', badge);

  info = CND.get_logger('info', badge);

  whisper = CND.get_logger('whisper', badge);

  alert = CND.get_logger('alert', badge);

  debug = CND.get_logger('debug', badge);

  warn = CND.get_logger('warn', badge);

  help = CND.get_logger('help', badge);

  urge = CND.get_logger('urge', badge);

  echo = CND.echo.bind(CND);

  //...........................................................................................................
  test = require('guy-test');

  L = this;

  ref = ['./sqy-lexer.test.js', './sqy-grammar.test.js'];
  for (i = 0, len = ref.length; i < len; i++) {
    path = ref[i];
    debug('µ28883', path);
    module = require(path);
    for (name in module) {
      value = module[name];
      if (CND.isa_function(value)) {
        L[name] = value.bind(L);
      } else {
        L[name] = value;
      }
    }
    test(L);
  }

}).call(this);

//# sourceMappingURL=main.js.map