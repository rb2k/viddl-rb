
# ParameterParser parses the program parameters.
# If the parameters are not valid in some way an exception is raised.
class ParameterParser

  DEFAULT_SAVE_DIR = "."

  #returns a hash with the parameters in it:
  # :url            => the video url
  # :extract_audio  => should attempt to extract audio? (true/false)
  # :url_only       => do not download, only print the urls to stdout
  # :title_only     => do not download, only print the titles to stdout
  # :youtube_filer  => a regular expression used ot fileter youtube playlists
  # :save_dir       => the directory where the videos are saved
  def self.parse_app_parameters
    check_valid_parameters!

    params = {}
    params[:url] = ARGV.first
    params[:extract_audio] = ARGV.include?("--extract-audio")
    params[:url_only] = ARGV.include?("--url-only")
    params[:title_only] = ARGV.include?("--title-only")
    params[:youtube_filter] = get_youtube_filter
    params[:save_dir] = get_save_dir  
    params
  end

  #check if parameters are valid.
  #the exceptions raised by this method are caught by the viddl-rb bin utility.
  def self.check_valid_parameters!
    if ARGV.empty?
      raise "Usage: viddl-rb URL [--extract-audio]"
    elsif !ARGV.first.match(/^http/)
      raise "ERROR: Please include 'http' with your URL e.g. http://www.youtube.com/watch?v=QH2-TGUlwu4"
    elsif ARGV.include?("--extract-audio") && !DownloadHelper.os_has?("ffmpeg")
      raise "ERROR: To extract audio you need to have ffmpeg on your system"
    end
  end

  #gets the regular expression used to filter youtube playlists.
  def self.get_youtube_filter
    filter = ARGV.find { |arg| arg =~ /--filter=./ }  # --filter= and at least one more character
    return nil unless filter

    ignore_case = filter.include?("/i")
    regex = filter[/--filter=(.*?)(?:\/|$)/, 1]   # everything up to the first / (could be an empty string)
    raise "ERROR: '#{regex}' is not a valid regular expression" unless is_valid_regex?(regex)
    Regexp.new(regex, ignore_case)
  end

  #checks if the string is a valid regex (for example "*****" is not)
  def self.is_valid_regex?(regex)
    Regexp.compile(regex)
  rescue RegexpError
    false
  end
  
  #gets the directory used for saving videos in.
  def self.get_save_dir
    save_dir = ARGV.find { |arg| arg =~ /--save-dir=./ }
    return DEFAULT_SAVE_DIR unless save_dir

    dir = save_dir[/--save-dir=(.+)/, 1]
    raise "ERROR: '#{dir}' is not a valid directory or does not exist" unless File.directory?(dir)
    dir
  end
end
