module ViddlRb

  class RequirementError < StandardError; end

  class DownloadHelper

    class Tool
      attr_reader :name

      def initialize(name, &command_proc)
        @name = name
        @command_proc = command_proc
      end

      def get_command(download_url, save_path)
        @command_proc.call(download_url, save_path)
      end
    end

    # This array specifies the order of and how to invoke the different download tools.
    # A Tool is created with a name and block, where the block should evaluate to the cmd call
    # given a download url and a full file save path.
    TOOLS_PRIORITY_LIST = [

      Tool.new(:aria2c) do |url, path|
        "aria2c #{url.inspect} -U 'Wget/1.8.1' -x4 -d #{File.dirname(path).inspect} -o #{File.basename(path).inspect}"
      end,

      Tool.new(:wget) do |url, path|
        "wget #{url.inspect} -O #{path.inspect}"
      end,

      Tool.new(:curl) do |url, path|
        "curl -A 'Wget/1.8.1' --retry 10 --retry-delay 5 --retry-max-time 4  -L #{url.inspect} -o #{path.inspect}"
      end
    ]

    #simple helper that will save a file from the web and save it with a progress bar
    def self.save_file(file_url, file_name, user_opts = {})
      trap("SIGINT") { puts "goodbye"; exit }

      default_opts = {:save_dir => ".",
                      :amount_of_retries => 6,
                      :tool => get_default_tool}

      if user_tool = user_opts[:tool]
        user_opts[:tool] = TOOLS_PRIORITY_LIST.find { |tool| tool.name == user_tool } unless user_tool == :"net-http"
      else
        user_opts[:tool] = default_opts[:tool]
      end

      options = default_opts.merge(user_opts)
      file_path = File.expand_path(File.join(options[:save_dir], file_name))
      success = false

      #Some providers seem to flake out every now end then
      options[:amount_of_retries].times do |i|
        if options[:tool] == :"net-http"
          require_progressbar
          puts "Using net/http"
          success = download_and_save_file(file_url, file_path)
        else
          tool = options[:tool]
          puts "Using #{tool.name}"
          success = system tool.get_command(file_url, file_path)
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

    def self.get_default_tool
      tool = TOOLS_PRIORITY_LIST.find { |tool| ViddlRb::UtilityHelper.os_has?(tool.name) }
      tool || :net_http
    end

    def self.require_progressbar
      begin
        require "progressbar"
      rescue LoadError
        raise RequirementError,
          "you don't seem to have aria2, curl or wget on your system. In this case you'll need to install the 'progressbar' gem."
      end
    end

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
