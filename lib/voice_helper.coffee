LanguageDetect = require 'languagedetect'
fs = require 'fs'
lngDetector = new LanguageDetect()

Array.prototype.randomElement = ->
  @[Math.floor(Math.random() * @length)]

class VoiceHelper
  constructor: (@voices) ->

  voice: (text, hostname) ->
    language = @_language text
    key = "#{hostname}|#{language}"
    voice = @_prefered_voice key
    unless voice?
      voice = @_random_voice language
      @_prefered_voice key, voice
    voice

  _prefered_voice: (hostname, voice) ->
    filename = "#{__dirname}/../_temp/hostname_to_voice.json"
    content = if fs.existsSync(filename) then JSON.parse(fs.readFileSync(filename)) else {}
    if voice
      content[hostname] = voice
      fs.writeFileSync filename, JSON.stringify(content, " ", " ")
    else
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

(exports ? this).VoiceHelper = VoiceHelper