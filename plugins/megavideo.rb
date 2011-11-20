class Megavideo < PluginBase
	#this will be called by the main app to check whether this plugin is responsible for the url passed
	def self.matches_provider?(url)
		url.include?("megavideo.com")
	end
	
	def self.decrypt(un,k1,k2)
	#thanks to http://userscripts.org/scripts/review/42944
			k1 = k1.to_i
			k2 = k2.to_i

			#convert the hex "un" to binary
			location1 = Array.new
			un.each_char do |char|
				#puts "#{char} => #{char.to_i(16).to_s(2)}"
				location1 << ("000" + char.to_i(16).to_s(2))[-4,4]
			end
			
			location1 = location1.join("").split("")

			location6 = Array.new
			0.upto(383) do |n|
	        k1 = (k1 * 11 + 77213) % 81371
			k2 = (k2 * 17 + 92717) % 192811
			location6[n] = (k1 + k2) % 128
			end
			
		
			
			location3 = Array.new
			location4 = Array.new
			location5 = Array.new
			location8 = Array.new
			256.downto(0) do |n|
				location5 = location6[n]
				location4 = n % 128		
				location8 = location1[location5]
				location1[location5] = location1[location4]
				location1[location4] = location8
				
			end
				
			0.upto(127) do |n|
				location1[n] = location1[n].to_i ^ location6[n+256] & 1
			end
			
			location12 = location1.join("")
			location7 = Array.new
			
			n = 0
			while (n < location12.length) do
				location9 = location12[n,4]
				location7 << location9
				n+=4
			end

			result = ""
			location7.each do |bin|
				result = result + bin.to_i(2).to_s(16)
			end
			result
	end
	
	
	def self.get_urls_and_filenames(url)
		#the megavideo video ID looks like this: http://www.megavideo.com/?v=ABCDEF72 , we only want the ID (the \w in the brackets)
		video_id = url[/v[\/=](\w*)&?/, 1]
		puts "[MEGAVIDEO] ID FOUND: " + video_id
		video_page = Nokogiri::XML(open("http://www.megavideo.com/xml/videolink.php?v=#{video_id}"))
		info =  video_page.at("//ROWS/ROW")
		title = info["title"]
		puts "[MEGAVIDEO] title: #{title}"
		runtime = info["runtimehms"]
		puts "[MEGAVIDEO] runtime: #{runtime}"
		size = info["size"].to_i / 1024 / 1024
		puts "[MEGAVIDEO] size: #{size} MB"
		#lame crypto stuff		
		key_s = info["s"]
		key_un = info["un"]
		key_k1 = info["k1"]
		key_k2 = info["k2"]
		puts "[MEGAVIDEO] lame pseudo crypto keys:"
		puts "[MEGAVIDEO] s=#{key_s}"
		puts "[MEGAVIDEO] un=#{key_un}"
		puts "[MEGAVIDEO] k1=#{key_k1}"
		puts "[MEGAVIDEO] k2=#{key_k2}"
		puts "decrypting" 		
		download_url = "http://www#{key_s}.megavideo.com/files/#{decrypt(key_un,key_k1,key_k2)}/#{title}.flv"
		puts download_url
		puts "done decrypting" 
		file_name = title + ".flv"
		puts "downloading to " + file_name
		[{:url => download_url, :name => file_name}]
	end
	
end
