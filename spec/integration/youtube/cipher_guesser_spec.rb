
YOUTUBE_PLUGIN_PATH = File.join(File.dirname(File.expand_path(__FILE__)), '../../..', 'plugins/youtube')

require 'minitest/autorun'
require 'yaml'
require_relative File.join(YOUTUBE_PLUGIN_PATH, 'cipher_guesser.rb')

class CipherGuesserIntegrationTest < Minitest::Test

  def setup
    @cg = CipherGuesser.new
    @ciphers = read_cipher_array
  end

  def test_extracts_the_correct_cipher_operations_for_all_ciphers_in_the_ciphers_file
    
    @ciphers.each do |cipher|
      version    = cipher.first
      operations = cipher.last.split

      begin
        assert_equal operations, @cg.guess(version), "Guessed wrong for cipher version #{version.inspect}"
      rescue => e
        puts "Error guessing the cipher for version #{version.inspect}: #{e.message}"
        fail
      end
    end
  end

  private

  def read_cipher_array
    path = File.join(YOUTUBE_PLUGIN_PATH, "ciphers.yml")
    YAML.load_file(path).to_a
  end

end
