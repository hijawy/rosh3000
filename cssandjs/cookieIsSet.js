"use strict";
'use es6';

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.cookieIsSet = void 0;

var _operators = require("./operators");

const cookieIsSet = name => {
  return (0, _operators.getCookie)(name) !== null;
};

exports.cookieIsSet = cookieIsSet;