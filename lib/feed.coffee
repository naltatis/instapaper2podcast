jade = require 'jade'
fs = require 'fs'
dateFormat = require 'dateformat'

class Feed
  constructor: (@dropbox) ->
  path: ->
    "#{@dropbox.path}feed.rss"
  write: (items, cb) ->
    @_render items, (err, html) =>
      @_write html, cb
  _render: (items, cb) ->
    model = 
      items: items
      path: @dropbox.http
      dateFormat: dateFormat
    jade.renderFile 'feed.jade', locals: model, cb
  _write: (html, cb) ->
    fs.writeFile @path(), html, (err) ->
      cb err
        
(exports ? this).Feed = Feed