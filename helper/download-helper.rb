module ViddlRb

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
            progress_bar.file_transfer_mode   #to show download speed and file size
          end 
        },
        :progress_proc => lambda { |progress|
          progress_bar.set(progress) if progress_bar
        }) {|file| return file.read}        
    end
    
    #simple helper that will save a file from the web and save it with a progress bar
    def self.save_file(file_uri, file_name, save_dir = ".", amount_of_retries = 6)
      trap("SIGINT") { puts "goodbye"; exit }

      file_path = File.absolute_path(File.join(save_dir, file_name))
      #Some providers seem to flake out every now end then
      amount_of_retries.times do |i|
        if UtilityHelper.os_has?("wget")
          puts "using wget"
          `wget \"#{file_uri}\" -O #{file_path.inspect}`
        elsif UtilityHelper.os_has?("curl")
          puts "using curl"
          #-L means: follow redirects, We set an agent because Vimeo seems to want one
          `curl -A 'Wget/1.8.1' --retry 10 --retry-delay 5 --retry-max-time 4  -L \"#{file_uri}\" -o #{file_path.inspect}`
        else
         puts "using net/http"
          open(file_path, 'wb') { |file|          
            file.write(fetch_file(file_uri)); puts
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

  end
end
