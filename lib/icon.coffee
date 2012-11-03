urlColor = require './url_color'
mkdirp = require 'mkdirp'
fs = require 'fs'
exec = require('child_process').exec

#convert -size 1500x1500 background.png "radial-gradient:transparent-#2c7f0e" -compose multiply -flatten icon-2c7f0e.png; convert icon-2c7f0e.png logo.png -flatten icon-2c7f0e.png; convert icon-2c7f0e.png -resize 500x500 icon-2c7f0e.png
#convert -size 1500x1500 background.png "radial-gradient:transparent-#adadad" -compose multiply -flatten icon-adadad.png; convert icon-adadad.png logo.png -flatten icon-adadad.png; convert icon-adadad.png -resize 500x500 icon-adadad.png
#convert -size 1500x1500 background.png "radial-gradient:transparent-#bf1921" -compose multiply -flatten icon-bf1921.png; convert icon-bf1921.png logo.png -flatten icon-bf1921.png; convert icon-bf1921.png -resize 500x500 icon-bf1921.png
#convert -size 1500x1500 background.png "radial-gradient:transparent-#333333" -compose multiply -flatten icon-333333.png; convert icon-333333.png logo.png -flatten icon-333333.png; convert icon-333333.png -resize 500x500 icon-333333.png
#convert -size 1500x1500 background.png "radial-gradient:transparent-#7ab800" -compose multiply -flatten icon-7ab800.png; convert icon-7ab800.png logo.png -flatten icon-7ab800.png; convert icon-7ab800.png -resize 500x500 icon-7ab800.png
#convert -size 1500x1500 background.png "radial-gradient:transparent-#931f28" -compose multiply -flatten icon-931f28.png; convert icon-931f28.png logo.png -flatten icon-931f28.png; convert icon-931f28.png -resize 500x500 icon-931f28.png
#convert -size 1500x1500 background.png "radial-gradient:transparent-#423c78" -compose multiply -flatten icon-423c78.png; convert icon-423c78.png logo.png -flatten icon-423c78.png; convert icon-423c78.png -resize 500x500 icon-423c78.png
#convert -size 1500x1500 background.png "radial-gradient:transparent-#d73b00" -compose multiply -flatten icon-d73b00.png; convert icon-d73b00.png logo.png -flatten icon-d73b00.png; convert icon-d73b00.png -resize 500x500 icon-d73b00.png
#convert -size 1500x1500 background.png "radial-gradient:transparent-#eeeeee" -compose multiply -flatten icon-eeeeee.png; convert icon-eeeeee.png logo.png -flatten icon-eeeeee.png; convert icon-eeeeee.png -resize 500x500 icon-eeeeee.png
#convert -size 1500x1500 background.png "radial-gradient:transparent-#ffffff" -compose multiply -flatten icon-ffffff.png; convert icon-ffffff.png logo.png -flatten icon-ffffff.png; convert icon-ffffff.png -resize 500x500 icon-ffffff.png

class Icon
  constructor: (@item, @targetDir) ->
    @tempDir = "#{__dirname}/../_temp/"
    @assetsDir = "#{__dirname}/../assets/"
    mkdirp.sync @targetDir
    mkdirp.sync @tempDir
    @hex = urlColor(@item.url)

  path: ->
    "#{@targetDir}#{@filename()}"

  filename: ->
    hex = @hex.substr(1)
    "icon-#{hex}.jpg"

  get: (cb) ->
    callback = (err) =>
      @item.icon = @filename()
      cb err, @item

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
        cb err, @filename()

module.exports =
  Icon: Icon