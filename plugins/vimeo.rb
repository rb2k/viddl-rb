class Vimeo < PluginBase
  #this will be called by the main app to check whether this plugin is responsible for the url passed
  def self.matches_provider?(url)
    url.include?("vimeo.com")
  end
  
  def self.get_urls_and_filenames(url, options = {})
    #the vimeo ID consists of 7 decimal numbers in the URL
    vimeo_id = url[/\d{7,8}/]

    agent = Mechanize.new      #use Mechanize for the automatic cookie handeling
    agent.redirect_ok = false  #don't follow redirects so we do not download the video when we get it's url

    video_page = agent.get("http://vimeo.com/#{vimeo_id}")
    page_html = video_page.root.inner_html
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

    [{:url => download_url, :name => file_name}]
  end
end
