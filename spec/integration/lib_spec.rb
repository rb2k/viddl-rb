#encoding: utf-8

$LOAD_PATH << File.join(File.dirname(__FILE__), '../..', 'lib')

require 'minitest/autorun'
require 'rest_client'
require 'viddl-rb.rb'

class LibTest < Minitest::Test

  def test_can_get_single_youtube_url_and_filename
    can_get_single_youtube_url_and_filename("https://www.youtube.com/watch?v=kCfiKj8Iehk", "いいぜメーン")
  end

  def test_can_get_single_youtube_url_and_filename_for_non_embeddable_videos
    can_get_single_youtube_url_and_filename("http://www.youtube.com/watch?v=73rS-EnhP70", "kol")
  end

  def test_can_get_youtube_playlist
    download_urls = ViddlRb.get_urls_names("http://www.youtube.com/playlist?list=PL41AAC84379472529")
    assert download_urls.size == 3,
      "Expected size to be 3 but was #{download_urls.size}"
  end

  def test_can_extract_extensions_from_url_names
    download_urls = ViddlRb.get_urls_exts("http://www.youtube.com/watch?v=73rS-EnhP70")
    assert valid_youtube_extension?(download_urls.first[:ext])
  end

  def test_raises_plugin_error_when_plugin_fails
    assert_raises(ViddlRb::PluginError) do
      ViddlRb.get_urls("http://www.vimeo.com/thisshouldnotexist991122") # bogus url
    end
  end

  def test_returns_nil_when_url_is_not_recognized
    assert_nil(ViddlRb.get_urls("12345"))
    assert_nil(ViddlRb.get_urls("http://www.google.com"))
  end  

  private

  def can_get_single_youtube_url_and_filename(video_url, filename)
    download_urls = ViddlRb.get_urls_names(video_url)

    url = download_urls.first[:url]
    name = download_urls.first[:name]

    assert_match(/^#{filename}\./, name)                  # check that the name is correct
    assert_match(/^http/, url)                            # check that the string starts with http
    assert_match(/\/videoplayback\?/, url)                # check that we have the video playback string

    Net::HTTP.get_response(URI(url)) do |res|             # check that the location header is empty
      assert_nil(res["location"])
      break # break here because otherwise it will read the body for some reason (I think this is bug in Ruby)
    end
  end

  def valid_youtube_extension?(ext)
    valid = ViddlRb::Youtube::FormatPicker::FORMATS.map { |format| "." + format.extension }
    valid.include?(ext)
  end  
end
