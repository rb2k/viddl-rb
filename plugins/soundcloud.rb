require 'open-uri'
class Soundcloud < PluginBase
  # this will be called by the main app to check whether this plugin is responsible for the url passed
  def self.matches_provider?(url)
    url.include?("soundcloud.com")
  end

  # return the url for original video file and title
  def self.get_urls_and_filenames(url, options = {})
    doc          = Nokogiri::HTML(open(get_http_url(url)))
    download_filename = doc.at("#main-content-inner img[class=waveform]").attributes["src"].value.to_s.match(/\.com\/(.+)\_/)[1]
    download_url = "http://media.soundcloud.com/stream/#{download_filename}"
    file_name    = transliterate("#{doc.at('//h1/em').text.chomp}") + ".mp3"

    [{:url => download_url, :name => file_name}]
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
