require 'rubygems'
require 'minitest/autorun'
require 'rest_client'

class TestURLExtraction < MiniTest::Unit::TestCase
  def setup
  end

  #For now just one, downloads are big enough as it is and we don't want to annoy travis
  def test_youtube
    download_test('http://www.youtube.com/watch?v=CFw6s0TN3hY')
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
  
end
