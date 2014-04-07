require 'minitest/autorun'
require_relative "../../helper/download-helper.rb"
require_relative "../../helper/utility-helper.rb"
require 'fileutils'
require 'tmpdir'

class DownloadHelperTest < Minitest::Test
  def setup
    @dl_helper = ViddlRb::DownloadHelper
  end

  def test_the_helper_picks_the_best_available_tool
    tools_priority = @dl_helper::TOOLS_PRIORITY_LIST.map{|t| t.name.to_s}
    original_path = ENV['PATH']
    # We will replace PATH with just that new directory
    # then we'll make sure that the helper always picks the best available tool
    # TODO: Make sure this test works on Windows.
    begin
      Dir.mktmpdir do |dir|
        ENV['PATH'] = dir
        tools_priority.reverse.each do |tool|
          tool_path = File.join(dir, tool)
          FileUtils.touch(tool_path)
          assert_equal(ViddlRb::DownloadHelper.get_default_tool.name.to_s, tool)
        end
      end
    ensure
      ENV['PATH'] = original_path
    end
  end
end