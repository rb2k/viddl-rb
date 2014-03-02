class Youtube < PluginBase

  # this will be called by the main app to check whether this plugin is responsible for the url passed
  def self.matches_provider?(url)
    url.include?("youtube.com") || url.include?("youtu.be")
  end

  def self.get_urls_and_filenames(url, options = {})

    @url_resolver   = UrlResolver.new
    @video_resolver = VideoResolver.new(Decipherer.new(CipherLoader.new))
    @format_picker  = FormatPicker.new(options)

    urls = @url_resolver.get_all_urls(url, options[:filter])
    videos = get_videos(urls)

    return_value = videos.map do |video|
      format = @format_picker.pick_format(video)
      make_url_filname_hash(video, format)
    end

    return_value.empty? ? download_error("No videos could be downloaded.") : return_value
  end

  def self.notify(message)
    puts "[YOUTUBE] #{message}"
  end

  def self.download_error(message)
    raise CouldNotDownloadVideoError, message
  end

  def self.get_videos(urls)
    videos = urls.map do |url|
      begin
        @video_resolver.get_video(url)
      rescue VideoResolver::VideoRemovedError
        notify "The video #{url} has been removed."
      rescue => e
        notify "Error getting the video: #{e.message}"
      end
    end

    videos.reject(&:nil?)
  end

  def self.make_url_filname_hash(video, format)
    url = video.get_download_url(format.itag)
    name = PluginBase.make_filename_safe(video.title) + ".#{format.extension}"
    {url: url, name: name}
  end
end
