Seq = require 'seq'
rest = require 'restler'
jquery = require 'jquery'
jsdom = require 'jsdom'

class Instapaper
  constructor: (@config) ->
  items: (cb) ->
    self = @
    Seq()
      .seq ->
        self._list @
      .flatten()
      .seqEach (item) ->
        next = @
        return next() unless item.type == 'bookmark'
        self._get_text item.bookmark_id, (err, data) ->
          item.text = data
          next null, item
      .seq (items) ->
        console.log this.vars, "--"
        cb null, items
  _list: (cb) ->
    @_request 'bookmarks/list', limit: @config.items, cb
  _get_text: (id, cb) ->
    @_request 'bookmarks/get_text', bookmark_id: id, (err, html) ->
      document = jsdom.jsdom html
      window = document.createWindow()
      $ = jquery.create window
      cb null, $('#story').text()
  _request: (method, options, cb) ->
    defaults =
      username: @config.username
      password: @config.password
    options[name] = value for name, value of defaults
    url = "http://www.instapaper.com/api/1/#{method}"
    rest.get(url, query: options)
      .on('success', (data, res) -> cb null, data)
      .on('error', (data, res) -> cb new Error('request failed'), data)
      
(exports ? this).Instapaper = Instapaper