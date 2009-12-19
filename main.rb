$LOAD_PATH << './helper'

require "nokogiri"
require "open-uri"
require "download-helper.rb"
require "plugin-helper.rb"


if ARGV.first.nil?
	puts "Usage: viddl-rb [URL]!"
	exit
end

Dir["plugins/*.rb"].each do |plugin|
	load plugin
end

puts "Plugins loaded: #{PluginBase.registered_plugins}"


url = ARGV.first
puts "Analyzing URL: #{url}"
PluginBase.registered_plugins.sort.each do |plugin|
	if plugin.matches_provider?(url)
		puts "#{plugin}: true"
		plugin.download(url)
		exit
	else
		puts "#{plugin}: false"
	end
end

puts "No hit!"
