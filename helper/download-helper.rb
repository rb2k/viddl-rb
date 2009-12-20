require "open-uri"
require "progressbar" #http://github.com/nex3/ruby-progressbar

#usually not called directly
def fetch_file(uri)
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
def save_file(file_uri, file_name)  
  open(file_name, 'wb') { |file| 
    file.write(fetch_file(file_uri)); puts
  }
end
