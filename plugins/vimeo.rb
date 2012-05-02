require 'net/http'

class Vimeo < PluginBase
  #this will be called by the main app to check whether this plugin is responsible for the url passed
  def self.matches_provider?(url)
    url.include?("vimeo.com")
  end
  
  def self.get_urls_and_filenames(url)
    #the vimeo ID consists of 7 decimal numbers in the URL
    vimeo_id = url[/\d{7,8}/]

    page_html = open("http://vimeo.com/#{vimeo_id}").read

    title = page_html[/<meta\s+property="og:title"\s+content="(.+?)"/, 1]
    puts "[VIMEO] Title: #{title}"

    #the timestamp and sig info is in the embedded player javascript in the video page
    timestamp = page_html[/"timestamp":(\d+),/, 1]
    signature = page_html[/"signature":"([\d\w]+)",/, 1]

    #send a get request to the redirect url and pass along the id, sig and timestamp info
    redirect_uri = URI("http://player.vimeo.com/play_redirect?clip_id=#{vimeo_id}&sig=#{signature}&time=#{timestamp}&quality=hd&codecs=H264")
    redirect_res = Net::HTTP.get_response(redirect_uri)

    #the download url is the value of the location (redirect) header
    download_url = redirect_res["location"]
    file_name = make_filename(title)

    [{:url => download_url, :name => file_name}]
  end

  def self.make_filename(title)
    title.delete("\"'").gsub(/[^\d\w]/, '_') + ".mp4"
  end
end
