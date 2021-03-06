const fs = require('fs');
const path = require('path');
const https = require('https');

const express = require('express');
const favicon = require('serve-favicon');
const bodyParser = require('body-parser');

const R = require('ramda');
const { createMemoryHistory } = require('react-router');

const PROD = process.env.NODE_ENV === 'production';

const API = require('./src/node_modules/api.js');
const articleSelectors = require(
  './src/scripts/selectors/articleSelectors.js'
);
const createStore = require('./src/scripts/store.js');
const DB = require('./lib/db.js');
const defaultRouterHandler = require('./lib/defaultHandler.js');
const handleError = require('./lib/handleError.js');
const init = require('./src/scripts/init.js');
const logger = require('./lib/log.js');
const negotiateLang = require('./lib/negotiateLang.js');
const siteRouter = require('./routers/siteRouter.js');
const URL = require('./src/node_modules/urlHelpers.js');
const userRouter = require('./routers/userRouter.js');

const certsPath = path.resolve('/etc/letsencrypt/live/3rdhand.info');

const server = express();
server.use(favicon('./favicon.ico'));
server.use(bodyParser.json());
server.use(bodyParser.urlencoded({ extended: true }));

server.use(express.static(path.resolve(__dirname, 'dist')));
server.set('views', './views');
server.set('view engine', 'jade');

server.get('/index.atom', (req, res) => {
  const lang = negotiateLang(req);
  res.header('Content-Type', 'application/atom+xml; charset=utf8');
  const { store } = createStore(createMemoryHistory());
  init(store, {}, lang).then(() => {
    let { articles } = articleSelectors.containerSelector(store.getState());
    articles = articles.map(
      article => R.merge(article, { href: URL.getPath(article.urlParams) })
    );
    const updated = articles.length ? R.last(articles[0].updated) : '';
    const host = URL.getServerUrl(req);
    const root = `${host}/`;
    const url = host + req.url;
    res.render('feed', { articles, host, root, updated, url });
  });
});

server.get('/locales/:lang', (req, res) => {
  API.fetchLocaleStrings(req.params.lang).then(res.send.bind(res));
});

server.get('/signup', (req, res) => (
  DB.isSignupAllowed().then(isAllowed => {
    if (isAllowed) {
      return res.format({
        html() {
          return defaultRouterHandler(req, res);
        },
        default() {
          return res.status(204).end();
        },
      });
    }
    return res.sendStatus(404);
  })
));

server.post('/signup', (req, res) => (
  API.signup(req.body)
    .then(body => (
      res.format({
        html() {
          return res.redirect(303, URL.getUserPath(body.id));
        },
        default() {
          return res.send(body);
        },
      })
    )).catch(handleError.bind(null, res))
));

server.use('/users', userRouter);
server.use('/', siteRouter);

/* eslint-disable no-unused-vars */
server.use((err, req, res, next) => {
  /* eslint-enable no-unused-vars */
  const msg = err.message;
  if (msg === 'session timeout' || msg === 'token expired') {
    logger.warn(msg);
    return res.format({
      html() {
        res.status(404);
        return defaultRouterHandler(req, res);
      },
      default() {
        return res.sendStatus(404);
      },
    });
  }
  return handleError(res, err);
});

if (PROD) {
  const credentials = {
    key: fs.readFileSync(path.join(certsPath, 'privkey.pem')),
    cert: fs.readFileSync(path.join(certsPath, 'fullchain.pem')),
    ca: fs.readFileSync(path.join(certsPath, 'chain.pem')),
  };
  https.createServer(credentials, server).listen(8443, () => {
    logger.info('HTTPS server listening on port 8443...');
  });
}

server.listen(8081, () => {
  logger.info('Express web server listening on port 8081...');
});
