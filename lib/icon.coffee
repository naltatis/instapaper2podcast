urlColor = require './url_color'
mkdirp = require 'mkdirp'
fs = require 'fs'
exec = require('child_process').exec

class Icon
  constructor: (@item, @targetDir) ->
    @tempDir = "#{__dirname}/../_temp/"
    @assetsDir = "#{__dirname}/../assets/"
    mkdirp.sync @targetDir
    mkdirp.sync @tempDir

  path: ->
    "#{@targetDir}#{@filename()}"

  filename: ->
    hex = @hex.substr(1)
    "icon-#{hex}.jpg"

  _detect_color: (cb) ->
    urlColor @item.url, (err, hex) =>
      @hex = hex
      cb()

  get: (cb) ->
    callback = (err) =>
      @item.iconFile = @filename()
      @item.iconPath = @path()
      cb err, @item

    @_detect_color =>
      if fs.existsSync(@path())
        callback()
      else
        @_create callback

  _create: (cb) ->
    hex = @hex.substr(1)
    target = @path()
    command =
      """
      convert -size 1500x1500 #{@assetsDir}background.png "radial-gradient:transparent-##{hex}" -compose multiply -flatten #{@tempDir}icon-#{hex}.png;
      convert #{@tempDir}icon-#{hex}.png #{@assetsDir}logo.png -flatten -quality 40 #{target};
      rm #{@tempDir}icon-#{hex}.png
      """
    exec command, (err, stdout, stderr) =>
      console.log "created new icon:\t#{target}"
      cb null, @filename()

module.exports =
  Icon: Icon