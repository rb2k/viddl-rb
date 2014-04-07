
YOUTUBE_PLUGIN_PATH = File.join(File.dirname(File.expand_path(__FILE__)), '../../..', 'plugins/youtube')

require 'minitest/autorun'
require 'yaml'
require_relative File.join(YOUTUBE_PLUGIN_PATH, 'cipher_guesser.rb')

class CipherGuesserTest < Minitest::Test

  def setup
    @cg = CipherGuesser.new

    # Read local file instead of downloading
    def @cg.download_player_javascript(version)
      path = File.join(File.dirname(__FILE__), "player_js/html5player-#{version}.js")
      File.read(path)
    end
  end

  def test_extracts_the_correct_cipher_operations_from_the_player_javascript

    assert_equal %w[w30 r w30 w39],                   @cg.guess("en_US-vflLMtkhg")
    assert_equal %w[w48 s2 r s1 w4 w35],              @cg.guess("en_US-vflS1POwl")
    assert_equal %w[r s1 r s3 w19 r w35 w61 s2],      @cg.guess("ima-en_US-vflWnCYSF")
    assert_equal %w[r s1 w19 w9 w57 w38 s3 r s2],     @cg.guess("ima-vfl4_saJa")
    assert_equal %w[w68 w64 w28 r],                   @cg.guess("vfl9qWoOL")
    assert_equal %w[w32 r s2 w65 w26 w45 w24 w40 s2], @cg.guess("vflqSl9GX")

    #TODO: add these (will fail): vflZ4JlpT, vflNzKG7n
  end

end

