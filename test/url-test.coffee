expect = require 'expect'

URL = require '../src/scripts/url.coffee'

describe 'URL module', ->
	describe 'getParams', ->
		it 'returns a params object from a path', ->
			input = '/2015/09/29/slug/view'
			test =
				year: '2015'
				month: '09'
				day: '29'
				slug: 'slug'
				view: 'view'
			expect(URL.getParams input).toEqual test
		it 'supports a path with only lang', ->
			input = '/en'
			test =
				lang: 'en'
			expect(URL.getParams input).toEqual test
	describe 'getHref', ->
		it 'supports a path with only lang', ->
			path = '/en'
			params = URL.getParams path
			input = '/2015/09/29/'
			test = input + 'en'
			expect(URL.getHref input, params).toBe test
		it 'gives macrolanguage for macrolanguage', ->
			path = '/no'
			params = URL.getParams path
			input = '/test'
			test = input + '.no'
			expect(URL.getHref input, params).toBe test
	describe 'getPath', ->
		it 'can rebuild a path from params', ->
			path = '/2015/09/29/slug/view'
			params = URL.getParams path
			expect(URL.getPath params).toBe path
		it 'supports a path with only lang', ->
			path = '/en'
			params =
				lang: 'en'
			expect(URL.getPath params).toBe path
	describe 'setLang', ->
		it 'changes the lang in a path', ->
			input = '/2015/09/29/test.no'
			test = '/2015/09/29/test.en'
			expect(URL.setLang input, 'en').toBe test