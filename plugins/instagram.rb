class Instagram < PluginBase

  #this will be called by the main app to check whether this plugin is responsible for the url passed
  def self.matches_provider?(url)
    url.include?("instagram.com")
  end

  def self.get_urls_and_filenames(url, options = {})
    video_page = open(url).read

    download_url = video_page[/video_url":".*.mp4/][/http.*.mp4/].gsub('\/', '/')

    [{:url => download_url, :name => "#{Time.now.to_i}.mp4"}]
  end
end

