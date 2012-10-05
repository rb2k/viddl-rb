
# ParameterParser parses the program parameters.
# If the parameters are not valid in some way an exception is raised.
# The exceptions raised by this class are handeled in the bin program.

class ParameterParser

  DEFAULT_SAVE_DIR = "."

  #returns a hash with the parameters in it:
  # :url              => the video url
  # :extract_audio    => should attempt to extract audio? (true/false)
  # :url_only         => do not download, only print the urls to stdout
  # :title_only       => do not download, only print the titles to stdout
  # :playlist_filter  => a regular expression used to filter playlists
  # :save_dir         => the directory where the videos are saved
  def self.parse_app_parameters(args)

    # Default option values are set here
    options = {
      :extract_audio    => false,
      :url_only         => false,
      :title_only       => false,
      :playlist_filter  => nil,
      :save_dir         => DEFAULT_SAVE_DIR
    }

    optparse = OptionParser.new do |opts|
      opts.banner = "Usage: viddl-rb URL [options]"

      opts.on("-e", "--extract-audio", "Save video audio to file") do
        if ViddlRb::UtilityHelper.os_has?("ffmpeg")
          options[:extract_audio] = true
        else
          raise OptionParser::ParseError.new("to extract audio you need to have ffmpeg on your PATH")
        end
      end

      opts.on("-u", "--url-only", "Prints url without downloading") do
        options[:url_only] = true
      end

      opts.on("-t", "--title-only", "Prints title without downloading") do
        options[:title_only] = true
      end

      opts.on("-f", "--filter REGEX", Regexp, "Filters a video playlist according to the regex") do |regex|
        options[:filter] = regex
      end

      opts.on("-s", "--save-dir DIRECTORY", "Specifies the directory where videos should be saved") do |dir|
        if File.directory?(dir)
          options[:save_dir] = dir
        else
          raise OptionParser::InvalidArgument.new("'#{dir}' is not a valid directory")
        end
      end

      opts.on_tail('-h', '--help', 'Display this screen') do
        print_help_and_exit(opts)
      end
    end

    optparse.parse!(args)                           # removes all options from args
    print_help_and_exit(optparse) if args.empty?    # exit if no video url
    url = validate_url(args.first)                  # the url is the only element left
    options[:url] = url                     
    options
  end

  def self.print_help_and_exit(opts)
    puts opts
    exit(0)
  end

  def self.validate_url(url)
    if url =~ /^http/
      url
    else
      raise OptionParser::InvalidArgument.new(
        "please include 'http' with your URL e.g. http://www.youtube.com/watch?v=QH2-TGUlwu4")
    end
  end
end
