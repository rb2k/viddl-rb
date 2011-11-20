class Vimeo < PluginBase
	#this will be called by the main app to check whether this plugin is responsible for the url passed
	def self.matches_provider?(url)
		url.include?("vimeo.com")
	end
	
	def self.get_urls_and_filenames(url)
		#the vimeo ID consists of 7 decimal numbers in the URL
		vimeo_id = url[/\d{7,8}/]
		doc = Nokogiri::XML(open("http://www.vimeo.com/moogaloop/load/clip:#{vimeo_id}"))
		title = doc.at("//video/caption").inner_text
		puts "[VIMEO] Title: #{title}"
		request_signature = doc.at("//request_signature").inner_text
		request_signature_expires = doc.at("//request_signature_expires").inner_text
		

		puts "[VIMEO] Request Signature: #{request_signature} expires: #{request_signature_expires}"
		
		download_url = "http://www.vimeo.com/moogaloop/play/clip:#{vimeo_id}/#{request_signature}/#{request_signature_expires}/?q=hd"
		#todo: put the filename cleaning stuff into a seperate helper
		file_name = title.delete("\"'").gsub(/[^0-9A-Za-z]/, '_') + ".flv"
		puts "downloading to " + file_name
		[{:url => download_url, :name => file_name}]
	end
end