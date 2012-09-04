
# Downloader iterates over a download queue and downloads and saves each video in the queue.
class Downloader
  class DownloadFailedError < StandardError; end

  def download(download_queue, params)
    download_queue.each do |url_name|
      url = url_name[:url]
      name = url_name[:name]

      result = save_file(url, name, params[:save_dir])
      unless result
        raise DownloadFailedError, "Download for #{name} failed."
      else
        puts "Download for #{name} successful."
        AudioHelper.extract(name) if params[:extract_audio]
      end
    end
  end

  # TODO save_dir is not used yet
  def save_file(url, name, save_dir)
    DownloadHelper.save_file(url, name, save_dir)
  end
end
