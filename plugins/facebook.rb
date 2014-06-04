require 'uri'
require 'cgi'

class Facebook < PluginBase

  #this will be called by the main app to check whether this plugin is responsible for the url passed
  def self.matches_provider?(url)
    url.include?("facebook.com")
  end

  def self.get_urls_and_filenames(url, options = {})
    video_page = open(url).read

    title = video_page.scan(/<title.+>(.+)<\/title>/).flatten.first

    download_url = video_page[/https.*.mp4/].gsub(/\\u([\da-fA-F]{4})/) {|m| [$1].pack("H*").unpack("n*").pack("U*")}
    download_url = CGI::unescape(download_url)
    download_url = URI::extract(download_url.gsub('\\', '')).first

    file_name = PluginBase.make_filename_safe(title) + '.mp4'

    [{:url => download_url, :name => file_name}]
  end
end

