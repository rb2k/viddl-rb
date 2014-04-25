require 'open-uri'
require 'json'

class Bandcamp < PluginBase
  
  # this will be called by the main app to check whether this plugin is responsible for the url passed
  def self.matches_provider?(url)
    url.include?("bandcamp.com")
  end


  # return the url for original video file and title
  def self.get_urls_and_filenames(url, options = {})
    # locate the js object with all the tracks data
    url_and_files = []
    doc           = Nokogiri::HTML(open(get_http_url(url)))
    js            = doc.at("script:eq(9)").text
    match         = js[/trackinfo \: (\[\{.*\"\}\]),/, 1]
    
    # parse the js object
    JSON.parse(match).each do |track_data|
      track_url   = ''

      # hopefully the last is the best
      track_data['file'].each do |key, file|
        track_url = file
      end
      
      # create a good mp3 name
      track_name  = transliterate(track_data['title']) + '.mp3'
      
      # add to the response
      url_and_files << {url: track_url, name: track_name}
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
