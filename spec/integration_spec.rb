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
  
  def download_test(url)
    before = Dir['*']
    assert system("ruby bin/viddl-rb #{url}")
    new_file = Dir['*'] - before
    assert_equal new_file.size, 1
    assert File.size(new_file[0]) > 100000
    File.unlink(new_file[0])
  end
  
end
