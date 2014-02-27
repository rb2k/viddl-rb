
class VideoResolver

  class VideoRemovedError < StandardError; end

  CORRECT_SIGNATURE_LENGTH = 81
  SIGNATURE_URL_PARAMETER = "signature"

  def initialize(decipherer)
    @decipherer = decipherer
  end

  def get_video(url)
    @json = load_json(url)
    Video.new(get_title, parse_stream_map(get_stream_map))
  end

  private

  def load_json(url)
    html = open(url).read
    json_data = html[/ytplayer\.config\s*=\s*(\{.+?\});/m, 1] 
    MultiJson.load(json_data)
  end

  def get_stream_map
    stream_map = @json["args"]["url_encoded_fmt_stream_map"]
    raise VideoRemovedError.new if stream_map.nil? || stream_map.include?("been+removed")
    stream_map
  end

  def get_html5player_version
    @json["assets"]["js"][/html5player-(.+?)\.js/, 1]
  end

  def get_title
    @json["args"]["title"]
  end

  #
  # Returns a an array of hashes in the following format:
  # [
  #  {format: format_id, url: download_url},
  #  {format: format_id, url: download_url}
  #  ...
  # ]
  #
  def parse_stream_map(stream_map)
    entries = stream_map.split(",")

    parsed = entries.map { |entry| parse_stream_map_entry(entry) }
    parsed.each { |entry| apply_signature!(entry) if entry[:sig] }
    parsed
  end

  def parse_stream_map_entry(entry)
    # Note: CGI.parse puts each value in an array.
    params = CGI.parse((entry))

    {
      itag: params["itag"].first,
      sig:  fetch_signature(params),
      url:  url_decode(params["url"].first)
    }
  end

  # The signature key can be either "sig" or "s".
  # Very rarely there is no "s" or "sig" paramater. In this case the signature is already
  # applied and the the video can be downloaded directly.
  def fetch_signature(params)
    sig = params.fetch("sig", nil) || params.fetch("s", nil)
    sig && sig.first
  end

  def url_decode(text)
    while text != (decoded = CGI::unescape(text)) do
      text = decoded
    end
    text
  end

  def apply_signature!(entry)
    sig = get_deciphered_sig(entry[:sig])
    entry[:url] << "&#{SIGNATURE_URL_PARAMETER}=#{sig}"
    entry.delete(:sig)
  end

  def get_deciphered_sig(sig)
    return sig if sig.length == CORRECT_SIGNATURE_LENGTH
    @decipherer.decipher_with_version(sig, get_html5player_version)
  end

  class Video
    attr_reader :title

    def initialize(title, itags_urls)
      @title = title
      @itags_urls = itags_urls
    end

    def available_itags
      @itags_urls.map { |iu| iu[:itag] }
    end

    def get_download_url(itag)
      itag_url = @itags_urls.find { |iu| iu[:itag] == itag }
      itag_url[:url] if itag_url
    end
  end
end
