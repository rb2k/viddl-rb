require 'multi_json'

class ArtePlusSeven < PluginBase
  # this will be called by the main app to check whether this plugin is responsible for the url passed
  def self.matches_provider?(url)
    url.include?("arte.tv")
  end

  # return the url for original video file and title
  def self.get_urls_and_filenames(url, options = {})   
    id           = self.to_id(url)
    country      = self.extract_country(url)
    json_url     = "http://arte.tv/papi/tvguide/videos/stream/player/#{country}/#{id}_PLUS7-#{country.upcase}/ALL/ALL.json"
    doc          = MultiJson.load(open(json_url))['videoJsonPlayer']
    # This can be improved a lot,
    # check the results on http://floriancrouzat.net/arte/
    first_http_key = doc['VSR'].keys.find{|k| k.start_with?('HTTP')}
    download_url = doc['VSR'][first_http_key]['url']
    title        = doc['VTI']
    file_name    = PluginBase.make_filename_safe(title) + ".mp4"
    [{:url => download_url, :name => file_name}]
  end

  def self.to_id(url)
    url[/([\d-]+)/,1]
  end
  
  def self.extract_country(url)
    url_country = url[/\/guide\/(..)\//,1]
    mapping = {
      'de' => 'D',
      'fr' => 'F'
    }
    mapping[url_country]
    
  end
end
