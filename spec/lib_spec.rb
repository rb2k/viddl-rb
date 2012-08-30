
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

  def test_raises_download_error_when_video_cannot_be_downloaded
    assert_raises(ViddlRb::DownloadError) do
      ViddlRb.get_urls("http://www.youtube.com/watch?v=6TT19cB0NTM") # embedding is disabled for this video
    end
  end

  def test_raises_plugin_error_when_plugin_fails
    assert_raises(ViddlRb::PluginError) do
      ViddlRb.get_urls("http://www.dailymotion.com/***/") # bogus url
    end
  end

  def test_returns_nil_when_url_is_not_recognized
    assert_nil(ViddlRb.get_urls("12345"))
    assert_nil(ViddlRb.get_urls("http://www.google.com"))
  end
end
