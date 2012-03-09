rest = require 'restler'
jquery = require 'jquery'
jsdom = require 'jsdom'

_request = (method, options, cb) ->
  defaults =
    username: @config.username
    password: @config.password
  options[name] = value for name, value of defaults
  url = "http://www.instapaper.com/api/1/#{method}"
  rest.get(url, query: options)
    .on('success', (data, res) -> cb null, data)
    .on('error', (data, res) -> cb new Error('request failed'), data)

class Item
  constructor: (@config) ->
  load_text: (cb) ->
    @_request 'bookmarks/get_text', bookmark_id: @bookmark_id, (err, html) =>
      document = jsdom.jsdom html
      window = document.createWindow()
      $ = jquery.create window
      text = $('#story').text()
      cb null, @_cleanup(text)
  date: ->
    date = new Date()
    date.setTime @time * 1000
    date
  _cleanup: (text) ->
    text
      .replace(/[\n\t"]/g, ' ')
      .replace(/\$/g, '\$')
      .replace(/\ {2,}/g, ' ')
  _request: _request

class Instapaper
  constructor: (@config) ->
    @itemProto = new Item @config
  items: (cb) ->
    self = @
    @_list (err, items) ->
      result = []
      for item in items
        if item.type == 'bookmark'
          item.__proto__ = self.itemProto
          result.push item
      cb err, result
  _list: (cb) ->
    @_request 'bookmarks/list', limit: @config.items, cb
  _request: _request


(exports ? this).Instapaper = Instapaper