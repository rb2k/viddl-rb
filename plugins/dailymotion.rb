=begin
class Dailymotion < PluginBase

  #the video quality is choosen based on the following priority list:
  QUALITY_PRIORITY = %w[hd1080 hd720 hq sd ld]

  # this will be called by the main app to check whether this plugin is responsible for the url passed
  def self.matches_provider?(url)
    url.include?("dailymotion.com")
  end

  # return the url for original video file and title
  def self.get_urls_and_filenames(url, options = {})
    doc = Nokogiri::HTML(open(url))

    #check to see that the video is hosted on dailymotion.com - if not raise exception
    unless doc.xpath("//div[@class='dmco_html dmpi_video_partnerplayer']").empty?
      raise CouldNotDownloadVideoError,
            "This video is not hosted on dailymotion's own content servers. It can't be downloaded."
    end

    title     = doc.xpath("//meta[@property='og:title']").attribute("content").value 
    urls      = get_download_urls(doc)
    quality   = QUALITY_PRIORITY.find { |q| urls[q] }   #quality is the first quality from the priority list that exists for the video
    down_url  = urls[quality]
    extension = down_url[/(\.[\w\d]+)\?/, 1]
    file_name = PluginBase.make_filename_safe(title) + extension

    [{:url => unescape_url(down_url), :name => file_name}]
  end

  #returns a hash with the different video qualities mapped to their respective download urls
  def self.get_download_urls(doc)
    flashvars = doc.xpath("//div[@class='dmco_html player_box']/script").text   #the flash player script
    decoded = CGI::unescape(flashvars)
    url_array = decoded.scan(/(ld|sd|hq|hd720|hd1080)URL":"(.+?)"/).flatten     #group 1 = the quality, group 2 = the url
    Hash[*url_array]                                                            #hash like this: {"quality" => "url"}
  end

  #remove backslashes
  def self.unescape_url(url)
    url.gsub("\\", "")
  end
end
=end