config = require './config'
Instapaper = require('./lib/instapaper').Instapaper
Speech = require('./lib/speech').Speech
Feed = require('./lib/feed').Feed
Icon = require('./lib/icon').Icon
Seq = require('seq')

insta = new Instapaper config.instapaper
feed = new Feed config.dropbox

Seq()
  .seq ->
    insta.items @
  .flatten()
  .parMap 4, (item) ->
    speech = new Speech item, config.voices, config.dropbox
    speech.create_if_needed @
  .parMap 4, (item) ->
    icon = new Icon item, config.dropbox.path+"image/"
    icon.get @
  .unflatten()
  .seq (items) ->
    feed.write items, (err) ->
      console.log "done"