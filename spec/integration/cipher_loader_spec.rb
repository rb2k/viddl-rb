
require 'minitest/autorun'
require 'yaml'

class CipherLoaderTest < Minitest::Test

  CIPHER_YAML_PATH = "plugins/youtube/ciphers.yml"

  def test_cipher_loader_adds_new_ciphers_to_the_yaml_file_if_available
    ciphers = load_ciphers
    ciphers.keys[-5, 5].each { |key| ciphers.delete(key) }
    save_ciphers(ciphers)

    size_before = ciphers.size
    system "ruby bin/viddl-rb http://www.youtube.com/watch?v=CFw6s0TN3hY --url-only"
    size_after = load_ciphers.size

    assert size_after > size_before,
      "Expected size_after (#{size_after}) to be greater than size_before (#{size_before})"
  end

  private

  def load_ciphers
    YAML.load_file(CIPHER_YAML_PATH)
  end

  def save_ciphers(ciphers)
    File.write(CIPHER_YAML_PATH, ciphers.to_yaml)
  end
end
