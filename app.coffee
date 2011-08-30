config = require './config'
Instapaper = require('./lib/instapaper').Instapaper
Speech = require('./lib/speech').Speech
Feed = require('./lib/feed').Feed
Icon = require('./lib/icon').Icon
async = require 'async'

insta = new Instapaper config.instapaper
feed = new Feed config.dropbox

insta.items (err, items) ->
  console.log "got #{items.length} articles from instapaper"
  toSpeech = (item, cb) ->
    speech = new Speech item, config.voices, config.dropbox
    speech.create_if_needed (err, result) ->
      cb null, item
      #icon = new Icon item.url
      #icon.get (err, image) ->
      #  item.image = image
      #  cb null, item
    
  async.map items, toSpeech, (err, items) ->
    feed.write items, (err) ->
      console.log "done"