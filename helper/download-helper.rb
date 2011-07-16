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
  if `which wget`.include?("wget")
	puts "using wget"
  	IO.popen("wget \"#{unescaped_uri}\" -O #{file_name}", "r") { |pipe| pipe.each {|line| print line}}
  	result = ($?.exitstatus == 0)
  elsif `which curl`.include?("curl")
    puts "using curl"  
    #-L means: follow redirects, We set an agent because Vimeo seems to want one
    IO.popen("curl -A 'Mozilla/2.02 (OS/2; U)' -L \"#{unescaped_uri}\" -o #{file_name}", "r") { |pipe| pipe.each {|line| print line }}
  	result = ($?.exitstatus == 0)
  else
    open(file_name, 'wb') { |file|   	
      file.write(fetch_file(unescaped_uri)); puts
    }
    result = true
  end
  result
end
end