class DownloadHelper
#usually not called directly
  def self.fetch_file(uri)

  begin
  	require "progressbar" #http://github.com/nex3/ruby-progressbar
  rescue LoadError
  	puts "ERROR: You don't seem to have curl or wget on your system. In this case you'll need to install the 'progressbar' gem."
  	exit
  end
    progress_bar = nil 
    open(uri, :proxy => nil,
      :content_length_proc => lambda { |length|
        if length && 0 < length
          progress_bar = ProgressBar.new(uri.to_s, length)
        end 
      },
      :progress_proc => lambda { |progress|
        progress_bar.set(progress) if progress_bar
      }) {|file| return file.read}        
  end
  
  #simple helper that will save a file from the web and save it with a progress bar
  def self.save_file(file_uri, file_name)
    unescaped_uri = CGI::unescape(file_uri)
    result = false
    if os_has?("wget")
      puts "using wget"
      result = system("wget \"#{unescaped_uri}\" -O #{file_name}")
    elsif os_has?("curl")
      puts "using curl"
      #-L means: follow redirects, We set an agent because Vimeo seems to want one
    	result = system("curl -A 'Wget/1.8.1' -L \"#{unescaped_uri}\" -o #{file_name}")
    else
    	puts "using net/http"
      open(file_name, 'wb') { |file|   	      
        file.write(fetch_file(unescaped_uri)); puts
      }
      result = true
    end         
    result
  end
  
  #checks to see whether the os has a certain utility like wget or curl
  def self.os_has?(utility)
    windows = ENV['OS'] =~ /windows/i
    unless windows # if os is something else than Windows
      return `which #{utility}`.include?(utility)
    else # OS is Windows
      begin 
        `#{utility} --version` #if running the command does not throw an error, Windows has it. --version is for prettier console output.
        return true
      rescue Errno::ENOENT
        return false
      end
    end
  end
end
