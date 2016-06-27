React = require 'react'
Router = require 'react-router'
ReactRedux = require 'react-redux'

articleSelectors = require '../selectors/articleSelectors.js'
appSelectors = require '../selectors/appSelectors.js'

{ changePasswordSelector, loginSelector, signupSelector } = appSelectors

App = require './App.js'
authenticate = require './authenticate.js'

ArticleContainer = ReactRedux.connect(
  articleSelectors.containerSelector
)(require './ArticleContainer.js')
LoginDialog = ReactRedux.connect(loginSelector)(require './LoginDialog.js')
SignupDialog = ReactRedux.connect(signupSelector)(
  require './signup-dialog.coffee'
)
ChangePasswordDialog = ReactRedux.connect(changePasswordSelector)(
  authenticate require './ChangePasswordDialog.js'
)
AuthenticatedArticleContainer = ReactRedux.connect(loginSelector)(
  authenticate ArticleContainer
)

Route = React.createFactory Router.Route
IndexRoute = React.createFactory Router.IndexRoute
Redirect = React.createFactory Router.Redirect

module.exports = Route(
  path: '/', component: App
  IndexRoute component: ArticleContainer
  Route path: '(*/)login', component: LoginDialog
  Route path: 'signup', component: SignupDialog
  Route path: '/locales/:file', component: App
  Route path: 'users/:userId/change-password', component: ChangePasswordDialog
  Route path: 'users/:userId/logout', component: LoginDialog
  Route path: 'users/:userId', component: AuthenticatedArticleContainer
  Route path: 'users/:userId/*', component: AuthenticatedArticleContainer
  Route path: '*', component: ArticleContainer
)
