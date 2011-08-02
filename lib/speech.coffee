LanguageDetect = require 'languagedetect'
exec = require('child_process').exec
spawn = require('child_process').spawn
fs = require 'fs'
lngDetector = new LanguageDetect()

class Speech
  constructor: (@item, @voices, @dropbox) ->
  path: ->
    "#{@dropbox.path}#{@item.hash}.m4a"
  temp_path: ->
    "/tmp/instapaper-to-speech-#{@item.hash}.aiff"
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
        cb()
  create: (cb) ->
    @item.load_text (err, text) =>
      @_write_file text, cb
  _write_file: (text, cb) ->
    @_say text, (err) =>
      @_convert (err) =>
        cb err, @item
  _say: (text, cb) ->
    say = spawn "say", ['-v', @_voice(text), '-r', '180', '-o', @temp_path()]
    say.stdin.write text
    say.stdin.end()
    say.stderr.on 'data', (data) ->
      cb new Error data
    say.on "exit", (code) =>
      cb()
  _convert: (cb) ->
    exec "afconvert -f mp4f -d aac -s 3 -q 127 #{@temp_path()} #{@path()}", cb
  _voice: (text) ->
    languages = lngDetector.detect text
    for language in languages
      return @voices[language[0]] if @voices[language[0]]?
    return @voices.english
    
(exports ? this).Speech = Speech