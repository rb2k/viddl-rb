
$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')

require 'rubygems'
require 'minitest/autorun'
require 'viddl-rb.rb'

class TestURLExtraction < MiniTest::Unit::TestCase

  # Acceptance tests
  #_________________

  def test_can_get_single_youtube_url_and_filename
    download_urls = ViddlRb.get_urls_and_filenames("http://www.youtube.com/watch?v=QH2-TGUlwu4")
    url = download_urls.first[:url]

    assert_match(/^http:\/\/r13---arn06s03.c.youtube.com\/videoplayback/, url)
  end

  # Unit tests
  #_________________

end
