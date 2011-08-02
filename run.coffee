config = require './config'
Instapaper = require('./lib/instapaper').Instapaper
Speech = require('./lib/speech').Speech
Feed = require('./lib/feed').Feed
async = require 'async'

insta = new Instapaper config.instapaper
insta.items (err, items) ->
  toSpeech = (item, cb) ->
    speech = new Speech item, config.voices, config.dropbox
    speech.create_if_needed cb
    
  updateFeed = (cb) ->
    feed = new Feed config.dropbox
    feed.write items, cb
    
  async.map items, toSpeech, (err, results) ->
    updateFeed (err) ->
      console.log "feed written"