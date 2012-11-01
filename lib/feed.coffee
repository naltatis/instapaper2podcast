jade = require 'jade'
fs = require 'fs'
dateFormat = require 'dateformat'
url = require 'url'

domainFromUrl = (string) ->
  url.parse(string).hostname

class Feed
  constructor: (@dropbox) ->
  path: ->
    "#{@dropbox.path}podcast.xml"
  write: (items, cb) ->
    @_render items, (err, html) =>
      console.log "feed rendering error", err if err?
      @_write html, cb
  _render: (items, cb) ->
    model =
      items: items
      path: @dropbox.http
      dateFormat: dateFormat
      domainFromUrl: domainFromUrl
    jade.renderFile "#{__dirname}/../view/feed.jade", locals: model, cb
  _write: (html, cb) ->
    console.log "writing podcast file to #{@path()}"
    fs.writeFile @path(), html, (err) ->
      cb err

(exports ? this).Feed = Feed