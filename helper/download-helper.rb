module ViddlRb

  class RequirementError < StandardError; end

  class DownloadHelper

    #viddl will use the first of these tools it finds on the system to download the video.
    #if the system does not have any of these tools, net/http is used instead.
    TOOLS_PRIORITY_LIST = [:wget, :curl]

    #simple helper that will save a file from the web and save it with a progress bar
    def self.save_file(file_url, file_name, opts = {})
      trap("SIGINT") { puts "goodbye"; exit }

      #default options
      options = {:save_dir => ".",
                 :amount_of_retries => 6,
                 :tool => get_tool}

      opts[:tool] = options[:tool] if opts[:tool].nil?
      options.merge!(opts)

      file_path = File.expand_path(File.join(options[:save_dir], file_name))
      success = false

      #Some providers seem to flake out every now end then
      options[:amount_of_retries].times do |i|
        case options[:tool].to_sym
        when :wget
          puts "Using wget"
          success = system "wget \"#{file_url}\" -O #{file_path.inspect}"
        when :curl
          puts "Using curl"
          #-L means: follow redirects, We set an agent because Vimeo seems to want one
          success = system "curl -A 'Wget/1.8.1' --retry 10 --retry-delay 5 --retry-max-time 4  -L \"#{file_url}\" -o #{file_path.inspect}"
        else
          require_progressbar
          puts "Using net/http"
          success = download_and_save_file(file_url, file_path)
        end
        #we were successful, we're outta here
        if success
          break
        else
          puts "Download seems to have failed (retrying, attempt #{i+1}/#{options[:amount_of_retries]})"
          sleep 2
        end
      end
      success
    end

    def self.get_tool
      tool = TOOLS_PRIORITY_LIST.find { |tool| ViddlRb::UtilityHelper.os_has?(tool) }
      tool || :net_http
    end

    def self.require_progressbar
      begin
        require "progressbar"
      rescue LoadError
        raise RequirementError,
          "you don't seem to have curl or wget on your system. In this case you'll need to install the 'progressbar' gem."
      end
    end

    # downloads and saves a file using the net/http streaming api
    # return true if the download was successful, else returns false
    def self.download_and_save_file(download_url, full_path)
      final_url = UtilityHelper.get_final_location(download_url)    # follow all redirects
      uri = URI(final_url)
      file = File.new(full_path, "wb")
      file_size = 0

      Net::HTTP.start(uri.host, uri.port) do |http|
        http.request_get(uri.request_uri) do |res|
          file_size = res.read_header["content-length"].to_i
          bar = ProgressBar.new(File.basename(full_path), file_size)
          bar.file_transfer_mode
          res.read_body do |segment|
            bar.inc(segment.size)
            file.write(segment)
          end
        end
      end
      file.close
      print "\n"
      download_successful?(full_path, file_size)   #because Net::HTTP.start does not throw Net exceptions
    end

    def self.download_successful?(full_file_path, file_size)
      File.exist?(full_file_path) && File.size(full_file_path) == file_size
    end
  end
end
