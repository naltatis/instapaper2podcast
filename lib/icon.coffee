jquery = require 'jquery'
jsdom = require 'jsdom'
url = require 'url'

#convert -size 1500x1500 background.png "radial-gradient:transparent-#2c7f0e" -compose multiply -flatten icon-2c7f0e.png; convert icon-2c7f0e.png logo.png -flatten icon-2c7f0e.png; convert icon-2c7f0e.png -resize 500x500 icon-2c7f0e.png
#convert -size 1500x1500 background.png "radial-gradient:transparent-#adadad" -compose multiply -flatten icon-adadad.png; convert icon-adadad.png logo.png -flatten icon-adadad.png; convert icon-adadad.png -resize 500x500 icon-adadad.png
#convert -size 1500x1500 background.png "radial-gradient:transparent-#bf1921" -compose multiply -flatten icon-bf1921.png; convert icon-bf1921.png logo.png -flatten icon-bf1921.png; convert icon-bf1921.png -resize 500x500 icon-bf1921.png
#convert -size 1500x1500 background.png "radial-gradient:transparent-#333333" -compose multiply -flatten icon-333333.png; convert icon-333333.png logo.png -flatten icon-333333.png; convert icon-333333.png -resize 500x500 icon-333333.png
#convert -size 1500x1500 background.png "radial-gradient:transparent-#7ab800" -compose multiply -flatten icon-7ab800.png; convert icon-7ab800.png logo.png -flatten icon-7ab800.png; convert icon-7ab800.png -resize 500x500 icon-7ab800.png
#convert -size 1500x1500 background.png "radial-gradient:transparent-#931f28" -compose multiply -flatten icon-931f28.png; convert icon-931f28.png logo.png -flatten icon-931f28.png; convert icon-931f28.png -resize 500x500 icon-931f28.png
#convert -size 1500x1500 background.png "radial-gradient:transparent-#423c78" -compose multiply -flatten icon-423c78.png; convert icon-423c78.png logo.png -flatten icon-423c78.png; convert icon-423c78.png -resize 500x500 icon-423c78.png
#convert -size 1500x1500 background.png "radial-gradient:transparent-#d73b00" -compose multiply -flatten icon-d73b00.png; convert icon-d73b00.png logo.png -flatten icon-d73b00.png; convert icon-d73b00.png -resize 500x500 icon-d73b00.png
#convert -size 1500x1500 background.png "radial-gradient:transparent-#eeeeee" -compose multiply -flatten icon-eeeeee.png; convert icon-eeeeee.png logo.png -flatten icon-eeeeee.png; convert icon-eeeeee.png -resize 500x500 icon-eeeeee.png

class Icon
  constructor: (@link) ->
  get: (cb) ->
    jsdom.env @link, (err, window) =>
      $ = jquery.create window
      icon = @_icon $
      cb err, icon
  _icon: ($) ->
    href = $("meta[property='og:image'], meta[name='og:image']").attr('content')
    href = $('link[rel="apple-touch-icon"]').attr('href') if not href?
    href = @_absolute href if href?
    href
  _absolute: (href) ->
    url.resolve @link, href
(exports ? this).Icon = Icon