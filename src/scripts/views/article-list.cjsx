React = require 'react'
Reflux = require 'reflux'
DocumentTitle = require 'react-document-title'

utils = require '../utils.coffee'
articleActions = require '../actions/article-actions.coffee'
articleStore = require '../stores/article-store.coffee'
ArticleItem = require './article.cjsx'
ArticleEditor = require './article-editor.cjsx'

module.exports = React.createClass
	displayName: 'ArticleList'
	mixins: [
		Reflux.listenTo(articleStore, 'onUpdate')
	]
	fetch: (params) ->
		articleActions.fetch(params)
	onUpdate: (articles) ->
		@setState articles: articles
	getInitialState: ->
		@fetch @props.params unless articleStore.lastFetched
		{ articles: articleStore.articles }
	componentWillReceiveProps: (nextProps) ->
		@fetch nextProps.params
	render: ->
		articles = @state.articles
		lang = articleStore.lang
		isSingle = articles.length == 1
		title = (if isSingle then utils.localize(lang, articles[0].title) + ' - ' else '') + @props.title
		unless isSingle
			list = (<article key={ article._id }><ArticleItem data={ article }/></article> for article in articles)
		else
			data = doc: articles[0], lang: lang
			if @props.params.view
				list = <ArticleEditor data={ data } view={ @props.params.view }/>
			else
				list = <ArticleItem data={ data }/>
		<DocumentTitle title={ title }>
			<div>
				{ list }
			</div>
		</DocumentTitle>
