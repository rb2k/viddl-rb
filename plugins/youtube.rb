# -*- coding: utf-8 -*-

class Youtube < PluginBase

  # see http://en.wikipedia.org/wiki/YouTube#Quality_and_codecs
  # TODO: we don't have all the formats from the wiki article here
  VIDEO_FORMATS = {
    "38" => {:extension => "mp4",  :name => "MP4 Highest Quality 4096x3027 (H.264, AAC)"},
    "37" => {:extension => "mp4",  :name => "MP4 Highest Quality 1920x1080 (H.264, AAC)"},
    "22" => {:extension => "mp4",  :name => "MP4 1280x720 (H.264, AAC)"},
    "46" => {:extension => "webm", :name => "WebM 1920x1080 (VP8, Vorbis)"},
    "45" => {:extension => "webm", :name => "WebM 1280x720 (VP8, Vorbis)"},
    "44" => {:extension => "webm", :name => "WebM 854x480 (VP8, Vorbis)"},
    "43" => {:extension => "webm", :name => "WebM 480x360 (VP8, Vorbis)"},
    "18" => {:extension => "mp4",  :name => "MP4 640x360 (H.264, AAC)"},
    "35" => {:extension => "flv",  :name => "FLV 854x480 (H.264, AAC)"},
    "34" => {:extension => "flv",  :name => "FLV 640x360 (H.264, AAC)"},
    "5"  => {:extension => "flv",  :name => "FLV 400x240 (Soerenson H.263)"},
    "17" => {:extension => "3gp",  :name => "3gp"}
  }

  DEFAULT_FORMAT_ORDER = %w[38 37 22 46 45 44 43 18 35 34 5 17]
  VIDEO_INFO_URL       = "http://www.youtube.com/get_video_info?video_id="
  VIDEO_INFO_PARMS     = "&ps=default&eurl=&gl=US&hl=en"

  # this will be called by the main app to check whether this plugin is responsible for the url passed
  def self.matches_provider?(url)
    url.include?("youtube.com") || url.include?("youtu.be")
  end

  def self.get_urls_and_filenames(url, options = {})
    @quality    = options[:quality]
    filter      = options[:playlist_filter]
    parser      = PlaylistParser.new
    return_vals = []

    if playlist_urls = parser.get_playlist_urls(url, filter)
      playlist_urls.each { |url| return_vals << grab_single_url_filename(url, options) }
    else
      return_vals << grab_single_url_filename(url, options)
    end

    clean_return_values(return_vals)
  end

  def self.clean_return_values(return_values)
    cleaned = return_values.reject { |val| val == :no_embed }

    if cleaned.empty?
      download_error("No videos could be downloaded.")
    else
      cleaned
    end
  end

  def self.grab_single_url_filename(url, options)
    UrlGrabber.new(url, self, options).process
  end

  class UrlGrabber
    attr_accessor :url, :options, :plugin, :quality

    def initialize(url, plugin, options)
      @url     = url
      @plugin  = plugin
      @options = options
      @quality = options[:quality]
    end

    def process
      grab_url_embeddable(url) || grab_url_non_embeddable(url)
    end

    # VEVO video: http://www.youtube.com/watch?v=A_J7kEhY9sM
    # Non-VEVO video: http://www.youtube.com/watch?v=WkkC9cK8Hz0

    def grab_url_embeddable(url)
      video_info   = get_video_info(url)
      video_params = extract_video_parameters(video_info)

      unless video_params[:embeddable]
        Youtube.notify("VIDEO IS NOT EMBEDDABLE")
        return false
      end

      urls_formats    = extract_urls_formats(video_info)
      selected_format = choose_format(urls_formats)
      title           = video_params[:title]
      file_name       = PluginBase.make_filename_safe(title) + "." + VIDEO_FORMATS[selected_format][:extension]

      {:url => urls_formats[selected_format], :name => file_name}
    end

    def grab_url_non_embeddable(url)
      video_info      = open(url).read
      stream_map      = video_info[/url_encoded_fmt_stream_map\" *: *\"([^\"]+)\"/,1]
      urls_formats    = parse_stream_map(url_decode(stream_map))
      selected_format = choose_format(urls_formats)
      title           = video_info[/<meta name="title" content="([^"]*)">/, 1]
      file_name       = PluginBase.make_filename_safe(title) + "." + VIDEO_FORMATS[selected_format][:extension]

      # cleaning
      clean_url = urls_formats[selected_format].gsub(/\\u0026[^&]*/, "").split(',type=video').first
      {:url => clean_url, :name => file_name}
    end

    def get_video_info(url)
      id = extract_video_id(url)
      request_url = VIDEO_INFO_URL + id + VIDEO_INFO_PARMS
      open(request_url).read
    end

    def extract_video_parameters(video_info)
      video_params = CGI.parse(url_decode(video_info))

      {
        :title      => video_params["title"].first,
        :length_sec => video_params["length_seconds"].first,
        :author     => video_params["author"].first,
        :embeddable => (video_params["status"].first != "fail")
      }
    end

    def extract_video_id(url)
      # the youtube video ID looks like this: [...]v=abc5a5_afe5agae6g&[...], we only want the ID (the \w in the brackets)
      # addition: might also look like this /v/abc5-a5afe5agae6g
      # alternative:  video_id = url[/v[\/=]([\w-]*)&?/, 1]
      url = open(url).base_uri.to_s if url.include?("youtu.be")
      video_id = url[/(v|embed)[=\/]([^\/\?\&]*)/, 2]

      if video_id
        Youtube.notify("ID FOUND: #{video_id}")
        video_id
      else
        Youtube.download_error("No video id found.")
      end
    end

    def extract_urls_formats(video_info)
      stream_map = video_info[/url_encoded_fmt_stream_map=(.+?)(?:&|$)/, 1]
      parse_stream_map(stream_map)
    end

    def choose_format(urls_formats)
      available_formats = urls_formats.keys

      if @quality                        #if the user specified a format
        ext = @quality[:extension]
        res = @quality[:resolution]
        #gets a nested array with all the formats of the same res as the user wanted
        requested = VIDEO_FORMATS.select { |id, format| format[:name].include?(res) }.to_a

        if requested.empty?
          Youtube.notify "Requested format \"#{res}:#{ext}\" not found. Downloading default format."
          get_default_format(available_formats)
        else
          pick = requested.find { |format| format[1][:extension] == ext }             # get requsted extension if possible
          pick ? pick.first : get_default_format(requested.map { |req| req.first })   # else return the default format
        end
      else
        get_default_format(available_formats)
      end
    end

    def parse_stream_map(stream_map)
      urls = extract_download_urls(stream_map)
      formats_urls = {}

      urls.each do |url|
        format = url[/itag=(\d+)/, 1]
        formats_urls[format] = url
      end

      formats_urls
    end

    def extract_download_urls(stream_map)
      entries = stream_map.split("%2C")
      decoded = entries.map { |entry| url_decode(entry) }

      decoded.map do |entry|
        url = entry[/url=(.*?itag=.+?)(?:itag=|;|$)/, 1]
        sig = entry[/sig=(.+?)(?:&|$)/, 1]

        url + "&signature=#{sig}"
      end
    end

    def get_default_format(available)
      DEFAULT_FORMAT_ORDER.find { |default| available.include?(default) }
    end

    def url_decode(text)
      while text != (decoded = CGI::unescape(text)) do
        text = decoded
      end
      text
    end

  end

  def self.notify(message)
    puts "[YOUTUBE] #{message}"
  end

  def self.download_error(message)
    raise CouldNotDownloadVideoError, message
  end

  #
  # class PlaylistParser
  #_____________________

  class PlaylistParser

    PLAYLIST_FEED = "http://gdata.youtube.com/feeds/api/playlists/%s?&max-results=50&v=2"
    USER_FEED     = "http://gdata.youtube.com/feeds/api/users/%s/uploads?&max-results=50&v=2"

    def get_playlist_urls(url, filter = nil)
      @filter = filter

      if url.include?("view_play_list") || url.include?("playlist?list=")     # if playlist URL
        parse_playlist(url)
      elsif username = url[/\/user\/([\w\d]+)(?:\/|$)/, 1]                       # if user URL
        parse_user(username)
      else                                                                    # if neither return nil
        nil
      end
    end

    def parse_playlist(url)
      #http://www.youtube.com/view_play_list?p=F96B063007B44E1E&search_query=welt+auf+schwäbisch
      #http://www.youtube.com/watch?v=9WEP5nCxkEY&videos=jKY836_WMhE&playnext_from=TL&playnext=1
      #http://www.youtube.com/watch?v=Tk78sr5JMIU&videos=jKY836_WMhE

      playlist_ID = url[/(?:list=PL|p=)(.+?)(?:&|\/|$)/, 1]
      Youtube.notify "Playlist ID: #{playlist_ID}"
      feed_url = PLAYLIST_FEED % playlist_ID
      url_array = get_video_urls(feed_url)
      Youtube.notify "#{url_array.size} links found!"
      url_array
    end

    def parse_user(username)
      Youtube.notify "User: #{username}"
      feed_url = USER_FEED % username
      url_array = get_video_urls(feed_url)
      Youtube.notify "#{url_array.size} links found!"
      url_array
    end

    #get all videos and return their urls in an array
    def get_video_urls(feed_url)
      Youtube.notify "Retrieving videos..."
      urls_titles = {}
      result_feed = Nokogiri::XML(open(feed_url))
      urls_titles.merge!(grab_urls_and_titles(result_feed))

      #as long as the feed has a next link we follow it and add the resulting video urls
      loop do
        next_link = result_feed.search("//feed/link[@rel='next']").first
        break if next_link.nil?
        result_feed = Nokogiri::HTML(open(next_link["href"]))
        urls_titles.merge!(grab_urls_and_titles(result_feed))
      end

      filter_urls(urls_titles)
    end

    #extract all video urls and their titles from a feed and return in a hash
    def grab_urls_and_titles(feed)
      feed.remove_namespaces!  #so that we can get to the titles easily
      urls   = feed.search("//entry/link[@rel='alternate']").map { |link| link["href"] }
      titles = feed.search("//entry/group/title").map { |title| title.text }
      Hash[urls.zip(titles)]    #hash like this: url => title
    end

    #returns only the urls that match the --filter argument regex (if present)
    def filter_urls(url_hash)
      if @filter
        Youtube.notify "Using filter: #{@filter}"
        filtered = url_hash.select { |url, title| title =~ @filter }
        filtered.keys
      else
        url_hash.keys
      end
    end
  end
end
