
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
    name = download_urls.first[:name]

    assert_equal("Nyan_Nyan_10_hours.mp4", name)          # check that the name is correct
    assert_match(/^http/, url)                            # check that the string starts with http
    assert_match(/c.youtube.com\/videoplayback/, url)     # check that we have the video playback string

    Net::HTTP.get_response(URI(url)) do |res|             # check that the location header is empty
      assert_nil(res["location"])
      break # break here because otherwise it will read the body for some reason (I think this is bug in Ruby)
    end
  end

  def test_can_get_youtube_playlist
    download_urls = ViddlRb.get_urls_and_filenames("http://www.youtube.com/playlist?list=PL41AAC84379472529")
    assert(download_urls.size == 3)
  end

  # Unit tests
  #_________________
  
end
