require 'rubygems'
require 'minitest/autorun'
require 'rest_client'

class TestURLExtraction < MiniTest::Unit::TestCase
  def setup
  end

  def http_code_grabber(url)
    RestClient.head(url).code
  end

  def test_youtube
   result = `bin/viddl-rb http://www.youtube.com/watch?v=CFw6s0TN3hY --url-only`
   url_output = result.split("\n").last
   http_response_code = http_code_grabber(url_output)
   #Check that we COULD download the file
   assert_includes(url_output, 'http://')
   assert_equal(200, http_response_code)
  end

  def test_veoh
   result = `bin/viddl-rb http://www.veoh.com/watch/v23858585TPfM8M8z --url-only`
   url_output = result.split("\n").last
   http_response_code = http_code_grabber(url_output)
   #Check that we COULD download the file
   assert_includes(url_output, 'http://')
   assert_equal(200, http_response_code)
  end

  def test_megavideo
   result = `bin/viddl-rb http://www.megavideo.com/?v=U0YPI0SO --url-only`
   url_output = result.split("\n").last
   http_response_code = http_code_grabber(url_output)
   #Check that we COULD download the file
   assert_includes(url_output, 'http://')
   assert_equal(200, http_response_code)
  end

  def test_vimeo
   result = `bin/viddl-rb http://vimeo.com/32612483 --url-only`
   url_output = result.split("\n").last
   http_response_code = http_code_grabber(url_output)
   #Check that we COULD download the file
   assert_includes(url_output, 'http://')
   assert_equal(200, http_response_code)
  end

  def test_blip_tv
   result = `bin/viddl-rb http://blip.tv/red-vs-blue/red-vs-blue-episode-11-5526271 --url-only`
   url_output = result.split("\n").last
   http_response_code = http_code_grabber(url_output)  
   #Check that we COULD download the file
   assert_includes(url_output, 'http://')
   assert_equal(200, http_response_code)
  end



end
