# Downloader iterates over a download queue and downloads and saves each video in the queue.
class Downloader
  class DownloadFailedError < StandardError; end

  def download(download_queue, params)
    download_queue.each do |url_name|
      # Skip invalid invalid link
      next unless url_name

      # Url
      url = url_name[:url]
      name = url_name[:name]

      result = ViddlRb::DownloadHelper.save_file url,
                                                 name,
                                                 :save_dir => params[:save_dir],
                                                 :tool => params[:tool] && params[:tool].to_sym
      if result
        puts "Download for #{name} successful."
        url_name[:on_downloaded].call(true) if url_name[:on_downloaded]
        ViddlRb::AudioHelper.extract(name, params[:save_dir]) if params[:extract_audio]
      else
        url_name[:on_downloaded].call(false) if url_name[:on_downloaded]
        if params[:abort_on_failure]
          raise DownloadFailedError, "Download for #{name} failed."
        else
          puts "Download for #{name} failed. Moving onto next file."
        end
      end
    end
  end
end
