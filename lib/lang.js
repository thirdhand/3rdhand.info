const tags = require('language-tags');
const locale = require('locale');

const utils = require('../src/scripts/utils.js');

const supportedLocales = ['en', 'nb'];
const supportedLocalesObject = new locale.Locales(supportedLocales.join(','));

function isLanguage(lang) {
  return typeof lang == 'string' && !!tags.language(lang);
}

function isMacrolanguage(lang) {
  return isLanguage(lang) && tags.language(lang).scope() === 'macrolanguage';
}

const negotiateLang = utils.maybe(_lang => {
  let lang = _lang;
  if (isMacrolanguage(_lang)) {
    lang = tags.languages(_lang);
  }
  if (Array.isArray(_lang)) {
    lang = _lang.join(',');
  }
  const negotiated = (new locale.Locales(lang)).best(supportedLocalesObject);
  if (negotiated.defaulted) {
    return '';
  }
  return negotiated.toString();
});

module.exports = { isLanguage, negotiateLang, supportedLocales };
