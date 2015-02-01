require 'nokogiri'
require 'uri'
require 'json'

class Soundcloud < PluginBase
  # this will be called by the main app to check whether this plugin is responsible for the url passed
  def self.matches_provider?(url)
    url.include?("soundcloud.com")
  end


  # return the url for original audio file and title
  def self.get_urls_and_filenames(url, options = {})
    url_and_files = []

    track_id_url = "https://api.sndcdn.com/resolve?url=#{URI::encode(url)}&client_id=b45b1aa10f1ac2941910a7f0d10f8e28"
    track_id_response = open(track_id_url, {ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE}).read
    track_id_response_parsed = JSON.parse(track_id_response)
    title = track_id_response_parsed['title']
    track_id = track_id_response_parsed['id']
    download_metadata_url = "https://api.sndcdn.com/i1/tracks/#{track_id}/streams?client_id=b45b1aa10f1ac2941910a7f0d10f8e28"
    download_metadata_response = open(download_metadata_url, {ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE}).read
    download_url = JSON.parse(download_metadata_response)['http_mp3_128_url']
    
    url_and_files << {
          url:  download_url,
          name: self.make_filename_safe(title) + '.mp3'
    }

    url_and_files
  end

  def self.get_http_url(url)
    url.sub(/http:\/\//, "https:\/\/")
  end
end