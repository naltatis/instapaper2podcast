request = require 'superagent'
jquery = require 'jquery'
jsdom = require 'jsdom'
urlUtil = require 'url'
dateFormat = require 'dateformat'

_request = (method, options, cb) ->
  defaults =
    username: @config.username
    password: @config.password
  options[name] = value for name, value of defaults
  url = "http://www.instapaper.com/api/1/#{method}"
  request.get(url).query(options).end (res) ->
    cb null, res.text

class Item
  constructor: (@config) ->
  load_text: (cb) ->
    @_request 'bookmarks/get_text', bookmark_id: @bookmark_id, (err, html) =>
      jsdom.env
        html: html
        scripts: ['http://code.jquery.com/jquery.js']
        done: (errors, window) =>
          $ = window.$
          text = $('#story').text()
          cb null, @_cleanup(text)
  date: ->
    date = new Date()
    date.setTime @time * 1000
    date
  filename: ->
    host = @hostname()
    date = dateFormat(@date(), "yyyy.mm.dd")
    "#{date}_#{host}_#{@hash}"
  hostname: ->
    hostname = urlUtil.parse(@url).hostname
    hostname.replace(/^www\./, "")
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
    @_request 'bookmarks/list', limit: @config.items, (err, res) -> cb(err, JSON.parse(res))
  _request: _request


(exports ? this).Instapaper = Instapaper