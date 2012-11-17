spawn = require('child_process').spawn
exec = require('child_process').exec
fs = require 'fs'
mkdirp = require 'mkdirp'
VoiceHelper = require('./voice_helper').VoiceHelper

String.prototype.trunc = (n) ->
  @substr(0,n-1) + (if @length > n then '...' else '')

class Speech
  constructor: (@item, voices, @speed, @dropbox) ->
    @audioPath = @dropbox.path + "audio/"
    @voiceHelper = new VoiceHelper(voices)
  path: ->
    "#{@audioPath}#{@item.filename()}.m4a"
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
          @_stats =>
            cb null, @item
      else
        #console.log "audio file exists\t#{@item.filename()}.m4a"
        cb null, @item
  create: (cb) ->
    @item.load_text (err, body) =>
      text = "#{@item.title}[[slnc 1000]]#{body}[[slnc 5000]]"
      @_write_file text, cb
  _write_file: (text, cb) ->
    @_say text, (err) =>
      @_compress (err) =>
        @_coverArt (err) =>
          console.log "finished aac file\t#{@item.filename()}.m4a"
          cb err, @item
  _compress: (cb) ->
      exec "afconvert -f m4af -d aach '#{@path()}' '#{@path()}'", cb
  _coverArt: (cb) ->
    if @item.iconPath
      exec "mp4art --optimize --add '#{@item.iconPath}' '#{@path()}'", cb
  _say: (text, cb) ->
    voice = @voiceHelper.voice(text, @item.hostname())
    mkdirp.sync @audioPath
    console.log "say using #{voice}:\t#{@item.title.trunc(30)} \t(#{text.split(' ').length} words)"
    say = spawn "say", ['-v', voice, '-r', @speed, '-o', @path(), '--file-format=m4af', '--data-format=alac']
    say.stdin.write text
    say.stdin.end()
    say.stderr.on 'data', (data) ->
      throw new Error(data)
    say.on "exit", (code) =>
      cb null, @item
(exports ? this).Speech = Speech