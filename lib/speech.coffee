LanguageDetect = require 'languagedetect'
exec = require('child_process').exec
lngDetector = new LanguageDetect()

class Speech
  constructor: (@voices) ->
  toFile: (text, file, cb) ->
    console.log "say -v #{@_voice(text)} -r 180 -o #{file}"
  _voice: (text) ->
    languages = lngDetector.detect text
    for language in languages
      for lang, val of language
        return @voices[lang] if @voices[lang]?
    return @voices.english
    
(exports ? this).Speech = Speech