require 'minitest/autorun'
require 'rest_client'
require 'multi_json'

class URLExtractionTest < Minitest::Test
  def setup
  end


  def http_code_grabber(url, options = {})
    user_agent = options[:user_agent] || "Wget/1.8.1"
    http_method = options[:method] || :head
    RestClient.send(http_method, url, {:headers => {'User-Agent' => user_agent}}).code
  end

  def curl_code_grabber(url, user_agent = "Wget/1.8.1")
    curl_command = "curl --silent -I -L -A \"#{user_agent}\" \"#{url}\""
    result = `#{curl_command}`
    http_code = result.scan(/HTTP\/\d\.\d\s+(\d+)/).flatten.last
    http_code.to_i rescue 0  # if no match, return 0
  end

  def test_youtube
    result = `ruby bin/viddl-rb http://www.youtube.com/watch?v=CFw6s0TN3hY --url-only`
    assert_equal $?, 0
    can_download_test(result)
  end

  def test_youtube_vevo
    result = `ruby bin/viddl-rb https://www.youtube.com/watch?v=y6Sxv-sUYtM --url-only`
    assert_equal $?, 0
    can_download_test(result)
  end

  def test_arte_plus_seven
    response = RestClient.get('http://www.arte.tv/guide/de/plus7.json?regions=default%2CEUR_DE_FR%2CDE_FR%2CSAT%2CALL').to_str
    test_url = "http://www.arte.tv" + MultiJson.load(response)['videos'][0]['url']
    puts "Running test using URL: #{test_url}"
    result = `ruby bin/viddl-rb #{test_url} --url-only`
    assert_equal $?, 0
    can_download_test(result){|url_output| curl_code_grabber(url_output) }
  end

  # see http://en.wikipedia.org/wiki/YouTube#Quality_and_codecs for format codes
  def test_youtube_different_formats
    result = `ruby bin/viddl-rb http://www.youtube.com/watch?v=Zj3tYO9co44 --url-only --quality 640:360:mp4`
    assert_equal $?, 0
    can_download_test(result)
    assert result.include?("itag=18")

    result2 = `ruby bin/viddl-rb http://www.youtube.com/watch?v=Zj3tYO9co44 --url-only --quality *:720:*`
    assert_equal $?, 0
    can_download_test(result2)
    assert result2.include?("itag=22")
  end

  def test_veoh
    result = `ruby bin/viddl-rb http://www.veoh.com/watch/v23858585TPfM8M8z --url-only`
    assert_equal $?, 0
    can_download_test(result) { |url_output| http_code_grabber(url_output, {:method => :get}) }
  end

  def test_vimeo
    result = `ruby bin/viddl-rb http://vimeo.com/80209061 --url-only`
    assert_equal $?, 0
    can_download_test(result) {|url_output| curl_code_grabber(url_output) }
  end

  def test_vimeo_sd_video
    result = `ruby bin/viddl-rb http://vimeo.com/38372260 --url-only`
    assert_equal $?, 0
    can_download_test(result) {|url_output| curl_code_grabber(url_output) }
  end

  def test_soundcloud
    result = `ruby bin/viddl-rb http://soundcloud.com/rjchevalier/remembering-mavi-koy-wip --url-only`
    assert_equal $?, 0
    can_download_test(result) {|url_output| curl_code_grabber(url_output, {:method => :get}) }
  end

  def test_soundcloud_https
    result = `ruby bin/viddl-rb https://soundcloud.com/rjchevalier/remembering-mavi-koy-wip --url-only`
    assert_equal $?, 0
    can_download_test(result) {|url_output| curl_code_grabber(url_output, {:method => :get}) }
  end

  def test_blip_tv
    result = `ruby bin/viddl-rb http://blip.tv/red-vs-blue/red-vs-blue-episode-11-5526271 --url-only`
    assert_equal $?, 0
    can_download_test(result)
  end

  def test_bandcamp
    result = `ruby bin/viddl-rb http://fontarabie.bandcamp.com/track/cosmogonie --url-only`
    assert_equal $?, 0
    can_download_test(result) { |url_output| http_code_grabber(CGI::unescape(url_output), {:method => :get}) }
  end

  def test_instagram
    result = `ruby bin/viddl-rb http://instagram.com/p/jKLFyKslJ-/ --url-only`
    assert_equal $?, 0
    can_download_test(result) { |url_output| http_code_grabber(CGI::unescape(url_output), {:method => :get}) }
  end

  def test_facebook
    result = `ruby bin/viddl-rb "https://www.facebook.com/photo.php?v=101503003357454&set=vb.310080259100701&type=2&theater" --url-only`
    assert_equal $?, 0
    can_download_test(result) { |url_output| http_code_grabber(CGI::unescape(url_output), {:method => :get}) }
  end

  # NOTE: The Metacafe tests are skipped because plugin is currently broken.

  def test_metacafe
    skip "plugin broken"
    result = `ruby bin/viddl-rb http://www.metacafe.com/watch/7731483/video_preview_final_fantasy_xiii_2/ --url-only`
    assert_equal $?, 0
    can_download_test(result) { |url_output| http_code_grabber(url_output) }
  end

  # NOTE: The Dailymotion tests are skipped because plugin is currently broken.

  def test_dailymotion_hd
    skip "plugin broken"
    result = `ruby bin/viddl-rb http://www.dailymotion.com/video/xskcnf_make-kanye-famous-kony-2012-parody_fun --url-only`
    assert_equal $?, 0
    can_download_test(result) { |url_output| http_code_grabber(CGI::unescape(url_output)) }
  end

  def test_dailymotion_hq
    skip "plugin broken"
    result = `ruby bin/viddl-rb http://www.dailymotion.com/video/xswn4i_pussy-riot-supporters-await-verdict-outside-court_news --url-only`
    assert_equal $?, 0
    can_download_test(result) { |url_output| http_code_grabber(CGI::unescape(url_output)) }
  end

  private

  def can_download_test(result, &grabber)
    url_output = result.split("\n").last
    # Assert url includes http:// or https://
    assert((CGI.unescape(url_output) =~ /https?:\/\//) != nil)
    code_grabber = grabber || proc { |url_output| http_code_grabber(url_output) }
    tries = 0
    http_response_code = 0

    begin
      http_response_code = code_grabber.call(url_output)
    rescue StandardError => e
      if ( http_response_code.to_i == 200 || (tries +=1) > 6 )
        puts "Can't download #{url_output.inspect}. Received: #{http_response_code}"
        raise e
      else
        puts "Retrying HTTP Call because of: #{e.message}"
        sleep 5
        retry
      end
    end

    assert_equal(200, http_response_code)
  end
end
