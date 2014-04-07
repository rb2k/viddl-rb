
class VideoResolver

  class VideoRemovedError < StandardError; end

  CORRECT_SIGNATURE_LENGTH = 81
  SIGNATURE_URL_PARAMETER = "signature"

  def initialize(decipherer)
    @decipherer = decipherer
  end

  def get_video(url)
    @json         = load_json(url)
    decipher_data = @decipherer.get_decipher_data(get_html5player_version)
    url_data      = parse_stream_map(get_stream_map)

    decipher_signatures!(url_data, decipher_data)

    Video.new(get_title, url_data, decipher_data)
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
    entries.map { |entry| parse_stream_map_entry(entry) }
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
  # Very rarely there is no "s" or "sig" parameter. In this case the signature is already
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

  def decipher_signatures!(url_data, decipher_data)
    url_data.each do |entry|
      next unless entry[:sig]

      sig = @decipherer.decipher_with_operations(entry[:sig], decipher_data[:operations])
      entry[:url] << "&#{SIGNATURE_URL_PARAMETER}=#{sig}"
      entry.delete(:sig)
    end
  end


  class Video
    attr_reader :title

    def initialize(title, url_data, decipher_data)
      @title = title
      @url_data = url_data
      @decipher_data = decipher_data
    end

    def available_itags
      @url_data.map { |entry| entry[:itag] }
    end

    def get_download_url(itag)
      entry = @url_data.find { |entry| entry[:itag] == itag }
      entry[:url] if entry
    end

    def signature_guess?
      @decipher_data[:guess?]
    end

    def cipher_operations
      @decipher_data[:operations]
    end

    def cipher_version
      @decipher_data[:version]
    end
  end
end
