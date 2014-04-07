
require 'minitest/autorun'
require 'yaml'

class CipherLoaderTest < Minitest::Test

  CIPHER_YAML_PATH = "plugins/youtube/ciphers.yml"
  ORIGINAL_CIPHER_FILE = File.read(CIPHER_YAML_PATH)

  # Since we are modifying the ciphers.yml file in the tests, make sure that
  # the original file is restored after each test.
  def teardown
    File.write(CIPHER_YAML_PATH, ORIGINAL_CIPHER_FILE)
  end

  def test_cipher_loader_adds_new_ciphers_to_the_yaml_file_if_available
    ciphers = load_ciphers

    # Delete the last five ciphers and change the ETag
    ciphers.keys[-5, 5].each { |key| ciphers.delete(key) }
    ciphers["ETag"] = "123"

    # Save the current size of ciphers and write the new version to the file.
    size_before = ciphers.size
    save_ciphers(ciphers)

    # Run the Youtube plugin. This will update the ciphers.yml file.
    system "ruby bin/viddl-rb http://www.youtube.com/watch?v=CFw6s0TN3hY --url-only"

    size_after = load_ciphers.size

    # Assert that the number of ciphers after we run the Youtube plugin has increased.
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
