require 'rubygems'
require 'minitest/autorun'
require 'rest_client'
require 'progressbar'

class IntegrationTest < Minitest::Test
  def setup
  end

  #For now just one, downloads are big enough as it is and we don't want to annoy travis
  def test_youtube
    download_test('http://www.youtube.com/watch?v=CFw6s0TN3hY')
    download_test_other_tools('http://www.youtube.com/watch?v=9uDgJ9_H0gg')  # this video is only 30 KB
  end

  
  private
  
  #Test video download and audio extraction
  def download_test(url)
    before = Dir['*']
    assert system("ruby bin/viddl-rb #{url} --extract-audio --quality 360:webm --downloader aria2c")
    new_files = Dir['*'] - before
    assert_equal 2, new_files.size

    video_file = new_files.find { |file| file.include?(".webm") }
    audio_file = new_files.find { |file| file.include?(".ogg") }

    assert File.size(video_file) > 100000
    assert File.size(audio_file) > 40000

    File.unlink(new_files[0])
    File.unlink(new_files[1])
  end

  def download_test_other_tools(url)
    %w[net-http curl wget].shuffle.each do |tool|
      before = Dir['*']
      assert system("ruby bin/viddl-rb #{url} --downloader #{tool}")
      new_files = Dir['*'] - before
      assert_equal new_files.size, 1
      assert File.size(new_files[0]) > 28000
      File.unlink(new_files[0])
    end
  end
  
end
