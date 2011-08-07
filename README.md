About
-----
Apple added international high quality voices to OS X Lion. This script pulls your latest articles from Instapaper converts them to `aac` using OS X's `say` and `afconvert` commands. It uses Dropbox to host our audio files and the generated podcast feed.

Requirements
------------
* node.js -- `brew install node`
* [paid 1$ per month Instapaper subscription for full api access](http://www.instapaper.com/subscription)
* OSX Lion if you want more than multiple languages

Configuration
-------------
1. create your config file -- `cp config-sample.coffee config.coffee`
2. enter your Instapaper credentials
3. adjust the Dropbox path

### voices & language detection
You can add voices for the languages you need.  
How to for installing new voices on OS X Lion: [instructions](http://prohackingtricks.blogspot.com/2011/07/how-to-install-mac-os-x-lions-high.html)  
Language detection is done by [node-language-detect](https://github.com/FGRibreau/node-language-detect)

### Instapaper folders or starred articles
If you don't want all articles in your podcast you can change the `folder_id` to `starred` or specify the id of a folder - [more](http://www.instapaper.com/api/full)

Create your podcast
-------------------

### run it manually

`node run.js`

### run in the background using launchd

`cp instapaper2podcast.plist ~/Library/LaunchAgents/instapaper2podcast.plist`  
adjust the path in `~/Library/LaunchAgents/instapaper2podcast.plist`

The program will be executed every 20 minutes and check for new Instapaper articles.

Logging goes to `system.log` you can monitor using `Console.app`

Subscribe to your podcast
-------------------------
add `http://dl.dropbox.com/u/DROPBOX-ID/instapaper-podcast/podcast.xml` to your favorite podcast client

**- enjoy your podcast**