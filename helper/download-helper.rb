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
  def self.save_file(file_uri, file_name, amount_of_retries = 6)
    trap("SIGINT") { puts "goodbye"; exit }
    unescaped_uri = CGI::unescape(file_uri)
    #Some providers seem to flake out every now end then
    amount_of_retries.times do |i|
      if os_has?("wget")
        puts "using wget"
        `wget \"#{unescaped_uri}\" -O #{file_name}`
      elsif os_has?("curl")
        puts "using curl"
        #-L means: follow redirects, We set an agent because Vimeo seems to want one
      	`curl -A 'Wget/1.8.1' -L \"#{unescaped_uri}\" -o #{file_name}`
      else
    	 puts "using net/http"
        open(file_name, 'wb') { |file|   	      
          file.write(fetch_file(unescaped_uri)); puts
        }
      end  
      #we were successful, we're outta here
      if $? == 0
        break
      else
        puts "Download seems to have failed (retrying, attempt #{i+1}/#{amount_of_retries})"
        sleep 2
      end
    end    
    $? == 0
  end
  
  #checks to see whether the os has a certain utility like wget or curl
  def self.os_has?(utility)
    windows = ENV['OS'] =~ /windows/i
    return `which #{utility}`.include?(utility) unless windows # if not Windows

    #use where (simliar to which) if present to reduce console clutter
    begin
      has_where? ? `where #{utility}` : `#{utility}`
      return true
    rescue Errno::ENOENT
      return false
    end
  end

  #checks if Windows has the where utility (Server 2003 and later)
  def self.has_where?
    begin
      `where`
      true
    rescue Errno::ENOENT
      false
    end
  end
end
