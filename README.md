__viddl-rb:__  
Created by Marc Seeger (@rb2k)  
Repo: http://github.com/rb2k/viddl-rb  
[![Build Status](https://secure.travis-ci.org/rb2k/viddl-rb.png)](http://travis-ci.org/rb2k/viddl-rb) [![Dependency Status](https://gemnasium.com/rb2k/viddl-rb.png)](https://gemnasium.com/rb2k/viddl-rb)



__Installation:__  
gem install viddl-rb

__Usage:__  

Download a video:  
    viddl-rb http://www.youtube.com/watch?v=QH2-TGUlwu4

Download a video and extract the audio:  
    viddl-rb http://www.youtube.com/watch?v=QH2-TGUlwu4 --extract-audio 

In both cases we'll name the output file according to the video title.

Download all videos on a Youtube playlist:  
    viddl-rb http://www.youtube.com/playlist?list=PL7E8DA0A515924126

Download all videos from a Youtube user:  
    viddl-rb http://www.youtube.com/user/tedtalksdirector

Filter videos to download from a Youtube user/playlist:  
    viddl-rb http://www.youtube.com/user/tedtalksdirector --filter=internet/i

The --filter argument accepts a regular expression and will only download  
videos whose titles match the regex. The /i option does a case-insensitive search.

__Requirements:__

* curl/wget or the [progress bar](http://github.com/nex3/ruby-progressbar/) gem  
* [Nokogiri](http://nokogiri.org/)
* ffmpeg if you want to extract audio tracks from the videos


__Contributors:__

* [kl](https://github.com/kl): Windows support (who knew!), bug fixes, veoh plugin, metacafe plugin   
* [divout](https://github.com/divout) aka Ivan K: blip.tv plugin, bugfixes
* Sniper: bugfixes
* [Serabe](https://github.com/Serabe) aka Sergio Arbeo: packaging viddl as a binary
* [laserlemon](https://github.com/laserlemon): Adding gemnasium images to readme
