
$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')

require 'rubygems'
require 'minitest/autorun'
require 'rest_client'
require 'viddl-rb.rb'

class TestURLExtraction < MiniTest::Unit::TestCase

  # Acceptance tests
  #_________________

  def test_can_get_single_youtube_url_and_filename
    download_urls = ViddlRb.get_urls_and_filenames("http://www.youtube.com/watch?v=gZ8w4vVaOL8")
    url = download_urls.first[:url]

    assert_match(/^http/, url)                            # check that the string start with http
    assert_match(/c.youtube.com\/videoplayback/, url)     # check that we have the video playback string
  end

  # Unit tests
  #_________________

end
