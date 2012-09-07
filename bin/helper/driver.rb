
# The Driver class drives the application logic in the viddl-rb utility.
# It gets the correct plugin for the given url and passes a download queue
# (that it gets from the plugin) to the Downloader object which downloads the videos.
class Driver

  def initialize(param_hash)
    @params = param_hash
    @downloader = Downloader.new
  end

  #starts the downloading process or print just the urls or names.
  def start
    queue = get_download_queue

    if @params[:url_only]
      queue.each { |url_name| puts url_name[:url] }
    elsif @params[:title_only]
      queue.each { |url_name| puts url_name[:name] }
    else
      @downloader.download(queue, @params)
    end
  end

  private

  #finds the right plugins and returns the download queue.
  def get_download_queue
    url = @params[:url]
    plugin = ViddlRb::PluginBase.registered_plugins.find { |p| p.matches_provider?(url) }
    raise "ERROR: No plugin seems to feel responsible for this URL." unless plugin
    puts "Using plugin: #{plugin}"

    begin
      #we'll end up with an array of hashes with they keys :url and :name 
      plugin.get_urls_and_filenames(url, @params)
      
    rescue ViddlRb::PluginBase::CouldNotDownloadVideoError => e
      raise "ERROR: The video could not be downloaded.\n" +
            "Reason: #{e.message}"
    rescue StandardError => e
      raise "Error while running the #{plugin.name.inspect} plugin. Maybe it has to be updated?\n" +
            "Error: #{e.message}.\n" +
            "Backtrace:\n#{e.backtrace.join("\n")}"  
    end
  end
end
