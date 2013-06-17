require 'rubygems'
require 'minitest/autorun'
require 'rest_client'
require 'progressbar'

class TestURLExtraction < Minitest::Test
  def setup
  end

  #For now just one, downloads are big enough as it is and we don't want to annoy travis
  def test_youtube
    download_test('http://www.youtube.com/watch?v=CFw6s0TN3hY')
    download_test_net_http('http://www.youtube.com/watch?v=9uDgJ9_H0gg')  # this video is only 30 KB
  end

  
  private
  
  #Test video download and audio extraction
  def download_test(url)
    before = Dir['*']
    assert system("ruby bin/viddl-rb #{url} -e")
    new_files = Dir['*'] - before
    assert_equal new_files.size, 2
    assert File.size(new_files[0]) > 100000
    assert File.size(new_files[1]) > 40000
    File.unlink(new_files[0])
    File.unlink(new_files[1])
  end

  def download_test_net_http(url)
    before = Dir['*']
    assert system("ruby bin/viddl-rb #{url} -d net-http")
    new_files = Dir['*'] - before
    assert_equal new_files.size, 1
    assert File.size(new_files[0]) > 28000
    File.unlink(new_files[0])
  end
  
end
