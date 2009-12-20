class Youtube < PluginBase

	def self.matches_provider?(string)
		string.include?("youtube.com")
	end
	
	def self.download(url)
		
		require "cgi"
		
		video_id = url[/v=(\w*)&?/, 1]
		puts "ID FOUND: " + video_id
		
		video_info = CGI::unescape(open("http://youtube.com/get_video_info?video_id=#{video_id}").read)

		video_info_hash = Hash[*video_info.split("&").collect { |v| 
			[v.split("=")[0], v.split("=")[1]]
		}.flatten]
		
		title = video_info_hash["title"]
		length_s = video_info_hash["length_seconds"]
		token = video_info_hash["token"]

		
		#Standard = 34 <- flv
		#Medium = 18 <- mp4
		#High = 35 <- flv
		#720p = 22 <- mp4
		#1080p = 37 <- mp4
		#mobile = 17 <- 3gp
		# --> 37 > 22 > 35 > 18 > 34 > 17
		formats = video_info_hash["fmt_map"].split(",").map{|item| item.split("/").first}
		
		format_ext = Hash.new
		format_ext["37"] = ["mp4", "MP4 Highest Quality 1920x1080"]
		format_ext["22"] = ["mp4", "MP4 1280x720"]
		format_ext["35"] = ["flv", "FLV 854x480"]
		format_ext["34"] = ["flv", "FLV 640x360"]
		format_ext["18"] = ["mp4", "MP4 480x270"]
		format_ext["17"] = ["3gp", "3gp"]
		format_ext["5"] = ["flv", "old default?"]
		
		puts "[YOUTUBE] Title: #{title}"
		puts "[YOUTUBE] Length: #{length_s} s"
		puts "[YOUTUBE] t-parameter: #{token}"
		#best quality seems always to be firsts
		puts "[YOUTUBE] formats available: #{formats} (downloading ##{formats.first} -> #{format_ext[formats.first].last})"


		download_url = "http://www.youtube.com/get_video?video_id=#{video_id}&t=#{token}%3D&fmt=#{formats.first}"
		file_name = title.delete("\"'").gsub(/[^0-9A-Za-z]/, '_') + "." + format_ext[formats.first].first
		puts "downloading to " + file_name
		save_file(download_url, file_name)
	end
end
