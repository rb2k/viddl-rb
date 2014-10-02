require 'nokogiri'
require 'uri'
require 'json'

class Soundcloud < PluginBase
  # this will be called by the main app to check whether this plugin is responsible for the url passed
  def self.matches_provider?(url)
    url.include?("soundcloud.com")
  end


  # return the url for original video file and title
  def self.get_urls_and_filenames(url, options = {})
    url_and_files = []

    doc        = Nokogiri::HTML(open(get_http_url(url)))
    js         = doc.at("script:contains('_scPreload')").text

    track_data = JSON.parse js[/_scPreload\s*?=\s*?([\s\S]*?)$/,1].to_s

    track_data['data']['models/audible'].each do |track_data|
      params    = URI.encode_www_form 'app_version' => '6749d1a0',
                                      'client_id'   => 'b45b1aa10f1ac2941910a7f0d10f8e28',
                                      'policy'      => 'ALLOW'

      url_and_files << {
          url:  URI("#{track_data['stream_url']}?#{params}").to_s.to_s,
          name: self.make_filename_safe(track_data['title'].to_s) + '.mp3'
      }
    end


    # locate the controller script that contains all the tracks data
    # this will work for either artist's or track's pages
    doc.css('#main-content-inner .container + script').each do |container|
      match       = container.text.to_s.match(/\((\{.*\})\)/).to_a
      track_data  = JSON.parse(match[1])
      
      file_url    = track_data['streamUrl']
      file_name   = self.make_filename_safe(track_data['title'].to_s) + '.mp3'

      url_and_files << {url: file_url, name: file_name}
    end

    url_and_files
  end

  def self.get_http_url(url)
    url.sub(/http:\/\//, "https:\/\/")
  end
end