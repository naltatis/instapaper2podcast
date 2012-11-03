Color = require 'color'
request = require 'superagent'
url = require 'url'
fs = require 'fs'
exec = require('child_process').exec
crypto = require 'crypto'

Array.prototype.randomElement = ->
  @[Math.floor(Math.random() * @length)]

class UrlColor
  defaultColor: "#FFFFFF"
  constructor: (@url) ->

  download_favicon: (cb) ->
    faviconUrl = url.resolve(@url, "/favicon.ico")
    hash = crypto.createHash('md5').update(faviconUrl).digest('hex')

    request
      .get(faviconUrl)
      .buffer(false)
      .end (err, res) ->
        if res.status is 200
          data = ''
          res.setEncoding 'binary'
          res.on 'data', (chunk) ->
            data += chunk
          res.on 'end', ->
            file = "/tmp/instapaper-#{hash}.ico"
            fs.writeFile file, data, 'binary', (err) ->
              cb err, file
        else
          cb null, null

  primary_colors: (cb) ->
    @download_favicon (err, file) =>
      return cb null, [] if not file?
      exec "convert #{file} -colors 6 -unique-colors -depth 8 txt:-", (err, stdout, stderr) =>
        return cb null, [] if err?
        colors = []
        for line in stdout.split("\n")
          match = line.match("#[0-9a-fA-F]{6}")
          colors.push match[0] if match?
        cb null, colors

  _cache: (path, color) ->
    hostname = url.parse(path).hostname

    filename = "#{__dirname}/../_temp/hostname_to_color.json"
    content = if fs.existsSync(filename) then JSON.parse(fs.readFileSync(filename)) else {}
    if color
      content[hostname] = color
      fs.writeFileSync filename, JSON.stringify(content, " ", " ")
    else
      content[hostname]

  primary_color: (cb) ->
    cached = @_cache(@url)
    if cached?
      cb null, cached
    else
      @primary_colors (err, colors) =>
        colors.sort (a, b) -> Color(b).saturation() - Color(a).saturation()
        result = colors[0] || @defaultColor
        @_cache @url, result
        cb err, result

urlColor = (url, cb) ->
  obj = new UrlColor(url)
  obj.primary_color cb

module.exports = urlColor