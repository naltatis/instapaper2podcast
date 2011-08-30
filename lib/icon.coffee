jquery = require 'jquery'
jsdom = require 'jsdom'
url = require 'url'

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