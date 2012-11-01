LanguageDetect = require 'languagedetect'
exec = require('child_process').exec
spawn = require('child_process').spawn
fs = require 'fs'
lngDetector = new LanguageDetect()

String.prototype.trunc = (n) ->
  @substr(0,n-1) + (if @length > n then '...' else '')

Array.prototype.randomElement = ->
  @[Math.floor(Math.random() * @length)]

class Speech
  constructor: (@item, @voices, @dropbox) ->
  path: ->
    "#{@dropbox.path}#{@item.hash}.m4a"
  temp_path: ->
    "/tmp/instapaper-to-speech-#{@item.hash}.aiff"
  _create_dir: (path) ->
    console.log "creating dir #{@dropbox.path}"
    fs.mkdirSync @dropbox.path, 0755
  _dir_exists: (path) ->
    try
      return fs.statSync @dropbox.path
    catch error
      return false
  _stats: (cb) ->
    fs.lstat @path(), (err, stat) =>
      @item.size = stat.size if stat?
      cb null, stat
  create_if_needed: (cb) ->
    @_stats (err, stat) =>
      if not stat?
        @create =>
          @_stats cb
      else
        console.log "skipping '#{@item.title}' - aac file already exists"
        cb()
  create: (cb) ->
    @item.load_text (err, text) =>
      @_write_file text, cb
  _write_file: (text, cb) ->
    @_say text, (err) =>
      @_convert (err) =>
        cb err, @item
  _say: (text, cb) ->
    voice = @_voice(text)
    console.log "say using #{voice}: '#{@item.title.trunc(30)}' (#{text.split(' ').length} words)"
    say = spawn "say", ['-v', voice, '-r', '220', '-o', @temp_path()]
    say.stdin.write text
    say.stdin.end()
    say.stderr.on 'data', (data) ->
      cb new Error data
    say.on "exit", (code) =>
      cb()
  _convert: (cb) ->
    @_create_dir @dropbox.path if not @_dir_exists @dropbox.path
    console.log "convert: aiff to aac '#{@item.title.trunc(30)}'"
    exec "afconvert -f m4af -d aac -s 3 -b 128000 #{@temp_path()} #{@path()}", cb
  _voice: (text) ->
    languages = lngDetector.detect text
    for language in languages
      return @_voiceByLanguage(language[0]) if @_voiceByLanguage(language[0])
    return  @_voiceByLanguage("english")
  _voiceByLanguage: (language) ->
    voices = @voices[language]
    if voices
      voices = [voices] if typeof voices is "string"
      voices.randomElement()
(exports ? this).Speech = Speech