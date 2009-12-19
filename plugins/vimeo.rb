class Vimeo < PluginBase
	def self.matches_provider?(string)
		if string.include?("vimeo.com")
			true
		else
			false
		end
	end
	
	def self.download(url)
		vimeo_id = url[/\d{7}/]
		doc = Nokogiri::HTML(open("http://www.vimeo.com/moogaloop/load/clip:#{vimeo_id}"))
		title = doc.at("//video/caption").inner_text
		request_signature = doc.at("//request_signature").inner_text
		request_signature_expires = doc.at("//request_signature_expires").inner_text
		
		puts "[VIMEO] Title: #{title}"
		puts "[VIMEO] Request Signature: #{request_signature} expires: #{request_signature_expires}"
		
		download_url = "http://www.vimeo.com/moogaloop/play/clip:#{vimeo_id}/#{request_signature}/#{request_signature_expires}/?q=hd"
		file_name = title.delete("\"'").gsub(/[^0-9A-Za-z]/, '_') + ".flv"
		puts "downloading to " + file_name
		save_file(download_url, file_name)
	end
end
