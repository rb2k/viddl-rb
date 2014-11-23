class Vimeo < PluginBase

  #this will be called by the main app to check whether this plugin is responsible for the url passed
  def self.matches_provider?(url)
    url.include?("vimeo.com")
  end
  
  def self.get_urls_and_filenames(url, options = {})
    #the vimeo ID consists of 7 decimal numbers or more in the URL
    vimeo_id = url[/\d{7,}/]

    video_url = "http://player.vimeo.com/video/#{vimeo_id}"
    video_page = RestClient.get(video_url)

    info_json = find_player_info(video_page)
    unless info_json
      raise CouldNotDownloadVideoError, "Could not find video urls\n" +
          "Please report this bug at github.com/rb2k/viddl-rb so it can be fixed!"
    end
    parsed = MultiJson.load(info_json)

    files = parsed["request"]["files"] 
    codecs = files["codecs"]

    unless codecs.include?("h264")
      raise CouldNotDownloadVideoError, "Unexpected codecs: #{codecs.inspect}\n" +
          "Please report this bug at github.com/rb2k/viddl-rb so it can be fixed!"
    end

    h264 = files["h264"]
    quality = ["hd", "sd"].find { |q| h264.keys.include?(q) }
    quality = h264.keys.first if quality.nil?

    download_url = h264[quality]["url"]
    extension = download_url[/.+?(\.[\w\d]+?)\?/, 1]
    file_name = PluginBase.make_filename_safe(parsed["video"]["title"]) + extension

    [{:url => download_url, :name => file_name}]
  end

  def self.find_player_info(string)
    # Based on http://stackoverflow.com/questions/25273624/ruby-regex-that-will-find-a-json-object-in-the-middle-of-a-string
    # Does also return some JSON primitives, so it not guaranteed that we only get objects, but we do not care as we are only
    # searching for one specific match that we know is a JSON object
    re = /
          (?:
            (?<number>  -?(?=[1-9]|0(?!\d))\d+(?:\.\d+)?(?:[eE][+-]?\d+)?)
            (?<boolean> true | false | null )
            (?<string>  " (?:[^"\\]++ | \\ ["\\bfnrt\/] | \\ u [0-9a-f]{4} )* " )
            (?<array>   \[ (?> \g<json> (?: , \g<json> )* )? \s* \] )
            (?<pair>    \s* \g<string> \s* : \g<json> )
            (?<object>  \{ (?> \g<pair> (?: , \g<pair> )* )? \s* \} )
            (?<json>    \s* (?> \g<number> | \g<boolean> | \g<string> | \g<array> | \g<object> ) \s*)
          ){0}
          \g<object>
        /uix


    string.scan(re).flatten.compact.select{|s| s.include? "vimeocdn.com"}.first
  end

end

