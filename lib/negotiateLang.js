const accepts = require('accepts');

const Lang = require('./lang.js');
const URL = require('../src/node_modules/urlHelpers.js');

const l = Lang.supportedLocales;

function negotiateLang(req) {
  const lang = URL.splitPath(req.url).filename.filter(Lang.isLanguage)[0];
  return Lang.negotiateLang(lang) || accepts(req).languages(l) || l[0];
}

module.exports = negotiateLang;
