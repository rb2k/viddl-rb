class Soundcloud < PluginBase
  require 'iconv'
  # this will be called by the main app to check whether this plugin is responsible for the url passed
  def self.matches_provider?(url)
    url.include?("soundcloud.com")
  end

  # return the url for original video file and title
  def self.get_urls_and_filenames(url)
    doc          = Nokogiri::XML(open(url))
    download_filename = doc.at("#main-content-inner img[class=waveform]").attributes["src"].value.to_s.match(/\.com\/(.+)\_/)[1]
    download_url = "http://media.soundcloud.com/stream/#{download_filename}"
    file_name    = transliterate("#{doc.at('//h1/em').text.chomp}") + ".mp3"

    [{:url => download_url, :name => file_name}]
  end

  def self.transliterate(str)
  # Based on permalink_fu by Rick Olsen

  # Escape str by transliterating to UTF-8 with Iconv
  s = Iconv.iconv('ascii//ignore//translit', 'utf-8', str).to_s

  # Downcase string
  s.downcase!

  # Remove apostrophes so isn't changes to isnt
  s.gsub!(/'/, '')

  # Replace any non-letter or non-number character with a space
  s.gsub!(/[^A-Za-z0-9]+/, ' ')

  # Remove spaces from beginning and end of string
  s.strip!

  # Replace groups of spaces with single hyphen
  s.gsub!(/\ +/, '-')

  return s
end

end
