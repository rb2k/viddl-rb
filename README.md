__viddl-rb:__  
Created by Marc Seeger (@rb2k)  
Repo: http://github.com/rb2k/viddl-rb  
[![Build Status](https://secure.travis-ci.org/rb2k/viddl-rb.png)](http://travis-ci.org/rb2k/viddl-rb)



__Installation:__  
gem install viddl-rb

__Usage:__  

Download a video:  
    viddl-rb http://www.youtube.com/watch?v=QH2-TGUlwu4

Download a video and extract the audio:  
    viddl-rb http://www.youtube.com/watch?v=QH2-TGUlwu4 --extract-audio 

In both cases we'll name the output file according to the video title.


__Requirements:__

* curl/wget or the [progress bar](http://github.com/nex3/ruby-progressbar/) gem  
* [Nokogiri](http://nokogiri.org/)
* ffmpeg if you want to extract audio tracks from the videos


__Contributors:__

* [kl](https://github.com/kl): Windows support (who knew!), bug fixes, veoh plugin, metacafe plugin   
* [divout](https://github.com/divout) aka Ivan K: blip.tv plugin, bugfixes
* Sniper: bugfixes
* [Serabe](https://github.com/Serabe) aka Sergio Arbeo: packaging viddl as a binary