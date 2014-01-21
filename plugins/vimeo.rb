
class Vimeo < PluginBase

  #this will be called by the main app to check whether this plugin is responsible for the url passed
  def self.matches_provider?(url)
    url.include?("vimeo.com")
  end
  
  def self.get_urls_and_filenames(url, options = {})
    #the vimeo ID consists of 7 decimal numbers in the URL
    vimeo_id = url[/\d{7,8}/]

    video_url = "http://player.vimeo.com/v2/video/#{vimeo_id}"
    video_page = open(video_url).read

    info_json = video_page[/a=({.+?);/, 1]
    parsed = JSON.parse(info_json)

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
end

=begin



    doc = Nokogiri::HTML(page_html)
    title = doc.at('meta[property="og:title"]').attributes['content'].value
    puts "[VIMEO] Title: #{title.inspect}"

    #the timestamp and sig info is in the embedded player javascript in the video page
    timestamp = page_html[/"timestamp":(\d+),/, 1]
    signature = page_html[/"signature":"([\d\w]+)",/, 1]

    redirect_url = "http://player.vimeo.com/play_redirect?clip_id=#{vimeo_id}&sig=#{signature}&time=#{timestamp}&quality=hd,sd&codecs=H264,VP8,VP6"

    #the download url is the value of the location (redirect) header
    download_url = agent.get(redirect_url).header["location"]
    file_name = PluginBase.make_filename_safe(title) + ".mp4"

  end
end
=end
