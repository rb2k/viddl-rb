require 'open-uri'
require 'json'

class Soundcloud < PluginBase
  # this will be called by the main app to check whether this plugin is responsible for the url passed
  def self.matches_provider?(url)
    url.include?("soundcloud.com")
  end


  # return the url for original video file and title
  def self.get_urls_and_filenames(url, options = {})
    url_and_files = []
    doc           = Nokogiri::HTML(open(get_http_url(url)))

    # locate the controller script that contains all the tracks data
    # this will work for either artist's or track's pages
    doc.css('#main-content-inner .container + script').each do |container|
      match       = container.text.to_s.match(/\((\{.*\})\)/).to_a
      track_data  = JSON.parse(match[1])
      
      file_url    = track_data['streamUrl']
      file_name   = transliterate(track_data['title'].to_s) + '.mp3'

      url_and_files << {url: file_url, name: file_name}
    end

    url_and_files
  end


  def self.transliterate(str)
    # Based on permalink_fu by Rick Olsen

    # Downcase string
    str.downcase!

    # Remove apostrophes so isn't changes to isnt
    str.gsub!(/'/, '')

    # Replace any non-letter or non-number character with a space
    str.gsub!(/[^A-Za-z0-9]+/, ' ')

    # Remove spaces from beginning and end of string
    str.strip!

    # Replace groups of spaces with single hyphen
    str.gsub!(/\ +/, '-')

    str
  end


  def self.get_http_url(url)
    url.sub(/https?:\/\//, "http:\/\/")
  end
end
