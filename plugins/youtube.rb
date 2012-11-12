require 'open-uri'

class Youtube < PluginBase

  VIDEO_INFO_URL = "http://www.youtube.com/get_video_info?video_id="

  VIDEO_FORMATS = {
    "38" => {:extension => "mp4", :name => "MP4 Highest Quality 4096x3027 (H.264, AAC)"},            
    "37" => {:extension => "mp4", :name => "MP4 Highest Quality 1920x1080 (H.264, AAC)"},
    "22" => {:extension => "mp4", :name => "MP4 1280x720 (H.264, AAC)"},
    "45" => {:extension => "webm", :name => "WebM 1280x720 (VP8, Vorbis)"},
    "44" => {:extension => "webm", :name => "WebM 854x480 (VP8, Vorbis)"},
    "18" => {:extension => "mp4", :name => "MP4 640x360 (H.264, AAC)"},
    "35" => {:extension => "flv", :name => "FLV 854x480 (H.264, AAC)"},
    "34" => {:extension => "flv", :name => "FLV 640x360 (H.264, AAC)"},
    "5"  => {:extension => "flv", :name => "FLV 400x240 (Soerenson H.263)"},
    "17" => {:extension => "3gp", :name => "3gp"}    
  }

  DEFAULT_FORMAT_ORDER = %w[38 37 22 45 44 18 35 34 5 7]

  #this will be called by the main app to check whether this plugin is responsible for the url passed
  def self.matches_provider?(url)
    url.include?("youtube.com") || url.include?("youtu.be")
  end
  
  #get all videos and return their urls in an array
  def self.get_video_urls(feed_url)
    notify "Retrieving videos..."
    urls_titles = Hash.new
    result_feed = Nokogiri::XML(open(feed_url))
    urls_titles.merge!(grab_urls_and_titles(result_feed))

    #as long as the feed has a next link we follow it and add the resulting video urls
    loop do   
      next_link = result_feed.search("//feed/link[@rel='next']").first
      break if next_link.nil?
      result_feed = Nokogiri::HTML(open(next_link["href"]))
      urls_titles.merge!(grab_urls_and_titles(result_feed))
    end

    self.filter_urls(urls_titles)
  end

  #returns only the urls that match the --filter argument regex (if present)
  def self.filter_urls(url_hash)
    if @filter
      notify "Using filter: #{@filter}"
      filtered = url_hash.select { |url, title| title =~ @filter }
      filtered.keys
    else
      url_hash.keys
    end
  end

  #extract all video urls and their titles from a feed and return in a hash
  def self.grab_urls_and_titles(feed)
    feed.remove_namespaces!  #so that we can get to the titles easily
    urls   = feed.search("//entry/link[@rel='alternate']").map { |link| link["href"] }
    titles = feed.search("//entry/group/title").map { |title| title.text } 
    Hash[urls.zip(titles)]    #hash like this: url => title
  end

  def self.parse_playlist(url)
    #http://www.youtube.com/view_play_list?p=F96B063007B44E1E&search_query=welt+auf+schwäbisch
    #http://www.youtube.com/watch?v=9WEP5nCxkEY&videos=jKY836_WMhE&playnext_from=TL&playnext=1
    #http://www.youtube.com/watch?v=Tk78sr5JMIU&videos=jKY836_WMhE

    playlist_ID = url[/(?:list=PL|p=)(\w{16})&?/,1]
    notify "Playlist ID: #{playlist_ID}"
    feed_url = "http://gdata.youtube.com/feeds/api/playlists/#{playlist_ID}?&max-results=50&v=2"
    url_array = self.get_video_urls(feed_url)
    notify "#{url_array.size} links found!"
    url_array
  end

  def self.parse_user(username)
    notify "User: #{username}"
    feed_url = "http://gdata.youtube.com/feeds/api/users/#{username}/uploads?&max-results=50&v=2"
    url_array = get_video_urls(feed_url)
    notify "#{url_array.size} links found!"
    url_array
  end

  def self.get_urls_and_filenames(url, options = {})
    @filter = options[:playlist_filter]                                    #used to filter a playlist in self.filter_urls
    @quality = options[:quality]

    return_values = []

    if url.include?("view_play_list") || url.include?("playlist?list=")    #if playlist
      notify "playlist found! analyzing..."
      files = parse_playlist(url)
      notify "Starting playlist download"
      files.each do |file|
        notify "Downloading next movie on the playlist (#{file})"
        return_values << grab_single_url_filename(file)
      end  
    elsif match = url.match(/\/user\/([\w\d]+)$/)                          #if user url, e.g. youtube.com/user/woot
      username = match[1]
      video_urls = parse_user(username)
      notify "Starting user videos download"
      video_urls.each do |url|
        notify "Downloading next user video (#{url})"
        return_values << grab_single_url_filename(url)
      end
    else                                                                   #if single video
      return_values << grab_single_url_filename(url)
    end 

    return_values.reject! { |value| value == :no_embed }                   #remove results that can not be downloaded

    if return_values.empty?
      raise CouldNotDownloadVideoError, "No videos could be downloaded - embedding disabled."
    else
      return_values
    end
  end
 
  def self.grab_single_url_filename(url)
    #the youtube video ID looks like this: [...]v=abc5a5_afe5agae6g&[...], we only want the ID (the \w in the brackets)
    #addition: might also look like this /v/abc5-a5afe5agae6g
    # alternative:  video_id = url[/v[\/=]([\w-]*)&?/, 1]
    # First get the redirect

    url = open(url).base_uri.to_s if url.include?("youtu.be")
    video_id = url[/(v|embed)[=\/]([^\/\?\&]*)/,2]
    video_id ? notify("ID FOUND: #{video_id}") : download_error("No video id found.")

    #let's get some infos about the video. data is urlencoded
    video_info = open(VIDEO_INFO_URL + video_id).read

    #converting the huge infostring into a hash. simply by splitting it at the & and then splitting it into key and value arround the =
    #[...]blabla=blubb&narf=poit&marc=awesome[...]
    video_info_hash = Hash[*video_info.split("&").collect { |v| 
      key, encoded_value = v.split("=")
      if encoded_value.to_s.empty?
        value = ""
      else
      #decode until everything is "normal"
        while (encoded_value != CGI::unescape(encoded_value)) do
          #"decoding"
          encoded_value = CGI::unescape(encoded_value)
        end
        value = encoded_value
      end

      if key =~ /_map/
        orig_value = value
        value = value.split(",")
        if key == "url_encoded_fmt_stream_map"
          url_array = orig_value.split("url=").map{|url_string| url_string.chomp(",")}
          result_hash = {}
          url_array.each do |url|
            next if url.to_s.empty? || url.to_s.match(/^itag/)
            format_id = url[/\&itag=(\d+)/, 1]
            result_hash[format_id] = url
          end
          value = result_hash
        elsif key == "fmt_map"
          value = Hash[*value.collect { |v| 
              k2, *v2 = v.split("/")
              [k2, v2]
            }.flatten(1)]
        elsif key == "fmt_url_map" || key == "fmt_stream_map"
          Hash[*value.collect { |v| v.split("|")}.flatten]
        end
      end
      [key, value]
    }.flatten]
    
    return :no_embed if video_info_hash["status"] == "fail"
      
    title = video_info_hash["title"]
    length_s = video_info_hash["length_seconds"]
    token = video_info_hash["token"]

    notify "Title: #{title}"
    notify "Length: #{length_s} s"
    notify "t-parameter: #{token}"

    #for the formats, see: http://en.wikipedia.org/wiki/YouTube#Quality_and_codecs
    fmt_list = video_info_hash["fmt_list"].split(",")

    selected_format = pick_video_format(fmt_list)
    puts "(downloading format #{selected_format} -> #{VIDEO_FORMATS[selected_format][:name]})"

    download_url = video_info_hash["url_encoded_fmt_stream_map"][selected_format]

    #if download url ends with a ';' followed by a codec string remove that part because it stops URI.parse from working
    
    if codec_part = download_url[/;\s*codec.+/m]    #if we have the ; codec substring  
      sig = codec_part[/&sig=(.+?)&/, 1]            #extract the signature

      download_url.sub!(codec_part, "")             #remove the ; codec substring from the download url
      download_url.concat("&signature=#{sig}")      #concatenate the correct signature attribute
    else
      download_url.sub!("&sig=", "&signature=")     #else we just have to change sig to signature
    end

    file_name = PluginBase.make_filename_safe(title) + "." + VIDEO_FORMATS[selected_format][:extension]
    puts "downloading to " + file_name + "\n\n"
    {:url => download_url, :name => file_name}
  end

  #returns the format of the video the user picked or the first default format if it does not exist
  def self.pick_video_format(fmt_list)
    available_formats = fmt_list.map { |format| format.split("/").first }
    notify "formats available: #{available_formats.inspect}"

    if @quality                         #if the user specified a format
      ext = @quality[:extension]
      res = @quality[:resolution]

      #gets a nested array with all the formats of the same res as the user wanted
      requested = VIDEO_FORMATS.select { |id, format| format[:name].include?(res) }.to_a

      if requested.empty?
        notify "Requested format \"#{res}:#{ext}\" not found. Downloading default format."
        get_default_format(available_formats)
      else
        pick = requested.find { |format| format[1][:extension] == ext }             #get requsted extension if possible
        pick ? pick.first : get_default_format(requested.map { |req| req.first })   #else return the default format
      end
    else
      get_default_format(available_formats)
    end
  end

  def self.get_default_format(available)
    DEFAULT_FORMAT_ORDER.find { |default| available.include?(default) }
  end

  def self.notify(message)
    puts "[YOUTUBE] #{message}"
  end
end
