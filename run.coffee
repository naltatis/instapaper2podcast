config = require './config'
Instapaper = require('./lib/instapaper').Instapaper
Speech = require('./lib/speech').Speech

speech = new Speech config.voices
insta = new Instapaper config.instapaper
insta.items (err, items) ->
  console.log err, items
  for item in items
    speech.toFile item.text