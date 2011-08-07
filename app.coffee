config = require './config'
Instapaper = require('./lib/instapaper').Instapaper
Speech = require('./lib/speech').Speech
Feed = require('./lib/feed').Feed
async = require 'async'

insta = new Instapaper config.instapaper
feed = new Feed config.dropbox

insta.items (err, items) ->
  console.log "got #{items.length} articles from instapaper"
  toSpeech = (item, cb) ->
    speech = new Speech item, config.voices, config.dropbox
    speech.create_if_needed cb
    
  async.map items, toSpeech, (err, results) ->
    feed.write items, (err) ->
      console.log "done"