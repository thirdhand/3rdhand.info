Reselect = require 'reselect'

utils = require '../utils.coffee'

localeSelector = (state) ->
	state = state.localeState
	return state.toJS()

loginSelector = (state) ->
	state = state.loginState.toJS()
	if utils.validLogin(state)
		return {
			isLoggedIn: true
			user: state.user
		}
	else
		return {
			isLoggedIn: false
		}

titleSelector = Reselect.createSelector [ localeSelector ], (localeState) ->
	return {
		title: localeState.localeStrings.title
	}

menuSelector = Reselect.createSelector(
	[localeSelector, loginSelector]
	(localeState, login) ->
		return {
			login: login
			localeStrings: localeState.localeStrings.SiteMenu
		}
)

module.exports =
	langPickerSelector: (state) ->
		return {
			localeStrings: state.localeState.toJS().localeStrings.LangPicker
		}
	linkSelector: (state) ->
		supportedLocales = state.localeState.get 'supportedLocales'
		state.navigationState.set('supportedLocales', supportedLocales).toJS()
	localeSelector: localeSelector
	loginSelector: Reselect.createSelector(
		[ loginSelector, localeSelector ]
		(state, localeState) ->
			state.localeStrings = localeState.localeStrings.LoginDialog
			state
	)
	menuSelector: menuSelector
	titleSelector: titleSelector