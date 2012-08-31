__viddl-rb:__  
Created by Marc Seeger (@rb2k)  
Repo: http://github.com/rb2k/viddl-rb  
LIB BRANCH STATUS: [![Build Status](https://secure.travis-ci.org/kl/viddl-rb.png)](http://travis-ci.org/kl/viddl-rb) [![Dependency Status](https://gemnasium.com/rb2k/viddl-rb.png)](https://gemnasium.com/rb2k/viddl-rb)

__Installation:__
If you want to try the library functionality do the following steps:

```
git clone https://github.com/kl/viddl-rb.git --branch="lib"
cd viddl-rb
gem build viddl-rb.gemspec
gem install viddl-rb-0.68.gem
```

__Usage:__  

Download a video:  
    viddl-rb http://www.youtube.com/watch?v=QH2-TGUlwu4

Download a video and extract the audio:  
    viddl-rb http://www.youtube.com/watch?v=QH2-TGUlwu4 --extract-audio 

In both cases we'll name the output file according to the video title.

__Youtube plugin specifics:__  

Download all videos on a playlist:  
    viddl-rb http://www.youtube.com/playlist?list=PL7E8DA0A515924126

Download all videos from a user:  
    viddl-rb http://www.youtube.com/user/tedtalksdirector

Filter videos to download from a user/playlist:  
    viddl-rb http://www.youtube.com/user/tedtalksdirector --filter=internet/i

The --filter argument accepts a regular expression and will only download videos where the title matches the regex.
The /i option does a case-insensitive search.

__Library Usage:__

```ruby
require 'viddl-rb'

download_urls = ViddlRb.get_urls("http://www.youtube.com/watch?v=QH2-TGUlwu4")
download_urls.first     # => "http://o-o.preferred.arn06s04.v3.lscac ..."
```

The ViddlRb module has the following module public methods:

* __get_urls_names(url)__
-- Returns an array of one or more hashes that has the keys :url which
points to the download url and :name which points to the name 
(which is a filename safe version of the video title with a file extension).
Returns nil if the url is not recognized by any plugins.

* __get_urls_exts(url)__
-- Same as get_urls_names but with just the file extension (for example ".mp4")
instead of the full filename, and the :name key is replaced with :ext.
Returns nil if the url is not recognized by any plugins.

* __get_urls(url)__
-- Returns an array of download urls for the specified video url.
Returns nil if the url is not recognized by any plugins.

* __get_names(url)__
-- Returns an array of filenames for the specified video url.
Returns nil if the url is not recognized by any plugins.

* __io=(io_object)__
-- By default all plugin output to stdout will be suppressed when the library is used.
If you are interested in the output of a plugin, you can set an IO object that
will receive all plugin output using this method. For example:

```ruby
require 'viddl-rb'

ViddlRb.io = $stdout     # plugins will now write their output to $stdout
```

All the __get__ methods in the ViddlRb module will raise either a ViddlRb::PluginError or a ViddlRb::DownloadError if the plugin fails. 
A ViddlRb::PluginError is raised if the plugin fails in an unexpected way, and a ViddlRb::DownloadError is raised if the video could not be downloaded for some reason. 
An example of that is if a Youtube video is not embeddable - then it can't be downloaded.

```ruby
begin
  ViddlRb.get_urls(video_url)
rescue ViddlRb::DownloadError => e
  puts "Could not get download url: #{e.message}"
rescue ViddlRb::PluginError => e
  puts "Plugin blew up! #{e.message}\n" +
       "Backtrace:\n#{e.backtrace.join("\n")}"
end
```

__Requirements:__

* curl/wget or the [progress bar](http://github.com/nex3/ruby-progressbar/) gem  
* [Nokogiri](http://nokogiri.org/)
* [Mechanize](http://mechanize.rubyforge.org/)
* ffmpeg if you want to extract audio tracks from the videos

__Contributors:__

* [kl](https://github.com/kl): Windows support (who knew!), bug fixes, veoh plugin, metacafe plugin   
* [divout](https://github.com/divout) aka Ivan K: blip.tv plugin, bugfixes
* Sniper: bugfixes
* [Serabe](https://github.com/Serabe) aka Sergio Arbeo: packaging viddl as a binary
* [laserlemon](https://github.com/laserlemon): Adding gemnasium images to readme
