jade = require 'jade'
fs = require 'fs'
dateFormat = require 'dateformat'

class Feed
  constructor: (@dropbox) ->
  path: ->
    "#{@dropbox.path}podcast.xml"
  iconPath: ->
    "#{@dropbox.path}podcast.jpg"
  write: (items, cb) ->
    @_render items, (err, html) =>
      console.log "feed rendering error", err if err?
      @_write html, cb
  _render: (items, cb) ->
    model =
      items: items
      path: @dropbox.http
      dateFormat: dateFormat
    jade.renderFile "#{__dirname}/../view/feed.jade", model, cb
  _write: (html, cb) ->
    #console.log "writing podcast file to #{@path()}"
    fs.writeFile @path(), html, (err) ->
      cb err
    unless fs.existsSync @iconPath()
      console.log "copying podcast logo to #{@iconPath()}"
      target = fs.createWriteStream @iconPath()
      fs.createReadStream("#{__dirname}/../assets/podcast.jpg").pipe(target)

(exports ? this).Feed = Feed