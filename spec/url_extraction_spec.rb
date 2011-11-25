require 'rubygems'
require 'minitest/autorun'
require 'rest_client'

class TestURLExtraction < MiniTest::Unit::TestCase
  def setup
  end

  def http_code_grabber(url, options = {})
    user_agent = options[:user_agent] || "Wget/1.8.1"
    http_method = options[:method] || :head
    RestClient.send(http_method, url, {:headers => {'User-Agent' => user_agent}}).code
  end

  def curl_code_grabber(url, user_agent = "Wget/1.8.1")
    `curl --silent -I -L -A "Wget/1.8.1" #{url} | grep "HTTP/"`.to_s.split("\n").last.split(" ")[1].to_i
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
   http_response_code = http_code_grabber(url_output, {:method => :get})
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
   result = `bin/viddl-rb http://vimeo.com/31744552 --url-only`
   url_output = result.split("\n").last
   #http_response_code = http_code_grabber(url_output)
   http_response_code = curl_code_grabber(url_output)
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


  def test_metacafe  
   result = `bin/viddl-rb http://www.metacafe.com/watch/7731483/video_preview_final_fantasy_xiii_2/ --url-only`
   url_output = result.split("\n").last
   http_response_code = http_code_grabber(CGI::unescape(url_output))
   #Check that we COULD download the file
   assert_includes(url_output, 'http')
   assert_equal(200, http_response_code)
  end
end
