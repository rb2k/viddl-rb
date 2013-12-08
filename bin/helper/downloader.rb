
# Downloader iterates over a download queue and downloads and saves each video in the queue.
class Downloader
  class DownloadFailedError < StandardError; end

  def download(download_queue, params)
    download_queue.each do |url_name|
      url = url_name[:url]
      name = url_name[:name]

      result = ViddlRb::DownloadHelper.save_file url,
                                                 name,
                                                 :save_dir => params[:save_dir],
                                                 :tool => params[:tool] && params[:tool].to_sym
      unless result
        if params[:abort_on_failure]
          raise DownloadFailedError, "Download for #{name} failed."
        else
          puts "Download for #{name} failed. Moving onto next file."
        end
      else
        puts "Download for #{name} successful."
        ViddlRb::AudioHelper.extract(name, params[:save_dir]) if params[:extract_audio]
      end
    end
  end
end
