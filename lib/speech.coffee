LanguageDetect = require 'languagedetect'
exec = require('child_process').exec
spawn = require('child_process').spawn
fs = require 'fs'
mkdirp = require 'mkdirp'
lngDetector = new LanguageDetect()

String.prototype.trunc = (n) ->
  @substr(0,n-1) + (if @length > n then '...' else '')

Array.prototype.randomElement = ->
  @[Math.floor(Math.random() * @length)]

class VoiceHelper
  constructor: (@voices) ->

  voice: (text, hostname) ->
    language = @_language text
    voice = @_prefered_voice hostname
    unless voice?
      voice = @_random_voice language
      @_prefered_voice hostname, voice
    voice

  _prefered_voice: (hostname, voice) ->
    filename = "#{__dirname}/../_temp/hostname_to_voice.json"
    content = if fs.existsSync(filename) then JSON.parse(fs.readFileSync(filename)) else {}
    if voice #set
      content[hostname] = voice
      fs.writeFileSync filename, JSON.stringify(content)
    else # get
      content[hostname]

  _language: (text) ->
    languages = lngDetector.detect text
    for language in languages
      if @voices[language[0]]
        return language[0]
    "english"

  _random_voice: (language) ->
    voices = @voices[language]
    if voices
      voices = [voices] if typeof voices is "string"
      voices.randomElement()


class Speech
  constructor: (@item, voices, @dropbox) ->
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
        console.log "skipping '#{@item.title.trunc(30)}' - aac file already exists"
        cb null, @item
  create: (cb) ->
    @item.load_text (err, text) =>
      @_write_file text, cb
  _write_file: (text, cb) ->
    @_say text, (err) =>
      console.log "finished aac file\t#{@item.filename()}.m4a"
      cb err, @item
  _say: (text, cb) ->
    voice = @voiceHelper.voice(text, @item.hostname())
    mkdirp.sync @audioPath
    console.log "say using #{voice}:\t #{@item.title.trunc(30)} \t(#{text.split(' ').length} words)"
    say = spawn "say", ['-v', voice, '-r', '220', '-o', @path(), '--file-format=m4af', '--data-format=aac']
    say.stdin.write text
    say.stdin.end()
    say.stderr.on 'data', (data) ->
      throw new Error(data)
    say.on "exit", (code) =>
      cb null, @item
(exports ? this).Speech = Speech