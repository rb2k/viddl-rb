class Instagram < PluginBase

  #this will be called by the main app to check whether this plugin is responsible for the url passed
  def self.matches_provider?(url)
    url.include?("instagram.com")
  end

  def self.get_urls_and_filenames(url, options = {})
    video_page = RestClient.get(url)

    download_url = video_page[/meta property="og:video" content="(.*\.mp4)/, 1]
    # Fallback
    download_url ||= video_page[/"video_url":"(http[^"]+.mp4)"/, 1]

    extracted_caption = video_page[/"caption":"([^"]+)"/, 1]
    if extracted_caption
      caption = PluginBase.make_filename_safe(extracted_caption)
    else
      caption = Time.now.to_i
    end

    [{:url => download_url, :name => "#{caption}.mp4"}]
  end
end

