
require 'open-uri'
require 'net/http'
require 'openssl'
require 'yaml'

class CipherLoader

  CIPHER_YAML_URL = "https://raw.github.com/rb2k/viddl-rb/master/plugins/youtube/ciphers.yml"
  CIPHER_YAML_PATH = File.join(ViddlRb::UtilityHelper.base_path, "plugins/youtube/ciphers.yml")

  def initialize
    @ciphers = YAML.load_file(CIPHER_YAML_PATH)
  end

  def load_ciphers
    begin
      update_ciphers
    rescue => e
      Youtube.notify "Error updating ciphers: #{e.message}. Continuing..."
    end

    @ciphers.dup
  end

  private

  def update_ciphers
    return if get_server_file_size == get_local_file_size

    @ciphers.merge!(download_server_ciphers)
    save_local_ciphers(@ciphers)
  end

  def get_local_file_size
    File.size(CIPHER_YAML_PATH)
  end

  def get_server_file_size 
    uri = URI.parse(CIPHER_YAML_URL)
    http = make_http(uri)
    head = Net::HTTP::Head.new(uri.request_uri)
    http.request(head)["Content-Length"].to_i
  end

  def make_http(uri)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    http.open_timeout = 2
    http.read_timeout = 2
    http
  end

  def download_server_ciphers
    YAML.load(open(CIPHER_YAML_URL).read)
  end

  def save_local_ciphers(ciphers)
    File.write(CIPHER_YAML_PATH, ciphers.to_yaml)
  end
end
