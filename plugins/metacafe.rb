# Note: unfortunaley, only videos that are hosted on Metacafe.com's content server can be downloaded.
# They have an URL that looks somehting like this: http://www.metacafe.com/watch/7731483/
# Vidoes that have URLs that look like this: http://www.metacafe.com/watch/cb-q78rA_lp9s1_9EJsqKJ5BdIHdDNuHa1l/ cannot be downloaded.

class Metacafe < PluginBase
  BASE_FILE_URL = "http://v.mccont.com/ItemFiles/%5BFrom%20www.metacafe.com%5D%20"
  API_BASE = "http://www.metacafe.com/api/"
  
  #this will be called by the main app to check whether this plugin is responsible for the url passed
  def self.matches_provider?(url)
    url.include?("metacafe.com")
  end
  
  def self.get_urls_and_filenames(url, options = {})
    video_id = get_video_id(url)
    info_url = API_BASE + "item/#{video_id}" #use the API to get the full video url
    info_doc = Nokogiri::XML(open(info_url))
    
    video_swf_url = get_video_swf_url(info_doc, video_id)
    
    #by getting the video swf url we get a http redirect url with all info needed
    http_response = Net::HTTP.get_response(URI(video_swf_url)) 
    redirect_url = CGI::unescape(http_response['location'])

    file_info = get_file_info(redirect_url, video_id)
    key_string = get_file_key(redirect_url)
    file_url_with_key = file_info[:file_url] + "?__gda__=#{key_string}"
        
    [{:url => file_url_with_key, :name => get_video_name(video_swf_url) + file_info[:extension]}]
  end
  
  def self.get_video_id(url)
    id = url[/watch\/(\d+)/, 1]
    unless id
      raise CouldNotDownloadVideoError, "Can only download videos that has the ID in the URL."
    end
    id
  end

  def self.get_video_swf_url(info_doc, video_id)
    video_url = info_doc.xpath("//rss/channel/item/link").text
    video_url.sub!("watch", "fplayer")
    video_url.sub!(/\/\z/, ".swf") # remove last '/' and add .swf in it's place
  end
    
  #$1 = file name part 1, $2 = file name part 2, $3 = file extension
  def self.get_file_info(redirect_url, video_id)
    redirect_url =~ /mediaURL.+?metacafe\.com%.+?%\d+\.(\d+)\.(\d+)(\.[\d\w]+)/                                                                       
    {:file_url => "#{BASE_FILE_URL}#{video_id}\.#{$1}\.#{$2}#{$3}", :extension => $3}
  end
                                                                                    
  def self.get_file_key(redirect_url)
    redirect_url[/key.+?value":"([\w\d]+)"/, 1]
  end
  
  def self.get_video_name(url)
    name =  url[/fplayer\/\d+\/([\d\w]+)\.swf/, 1]
    PluginBase.make_filename_safe(name)
  end
end
