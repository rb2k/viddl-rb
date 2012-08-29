#!/usr/bin/env ruby
$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'helper')

require "rubygems"
require "net/http"
require "nokogiri"
require "mechanize"
require "cgi"
require "open-uri"
require "stringio"
require "download-helper.rb"
require "plugin-helper.rb"

#require all plugins
Dir[File.join(File.dirname(__FILE__),"../plugins/*.rb")].each { |p| require p }

module ViddlRb
  class PluginError < StandardError; end

  def self.io=(io_object)
    PluginBase.io = io_object
  end

  #set the default PluginBase io object to a StringIO instance.
  #this will suppress any standard output from the plugins.
  self.io = StringIO.new
  
  #returns an array of hashes containing the download url(s) and filenames(s) 
  #for the specified video url.
  #if the url does not match any plugin, return nil and if a plugin
  #throws an error, throw PluginError.
  #the reason for returning an array is because some urls will give multiple
  #download urls (for example a Youtube playlist url).
  def self.get_urls_and_filenames(url)
    plugin = PluginBase.registered_plugins.find { |p| p.matches_provider?(url) }

    if plugin 
      begin
        #we'll end up with an array of hashes with they keys :url and :name
        urls_filenames = plugin.get_urls_and_filenames(url)
      rescue StandardError => e
        message = plugin_error_message(plugin, e)
        raise PluginError, message
      end
      follow_all_redirects(urls_filenames)
    else
      nil
    end
  end

  #returns an array of download urls for the given video url.
  def self.get_urls(url)
    urls_filenames = get_urls_and_filenames(url)
    urls_filenames.nil? ? nil : urls_filenames.map { |uf| uf[:url] }
  end

  #returns an array of filenames for the given video url.
  def self.get_filenames(url)
    urls_filenames = get_urls_and_filenames(url)
    urls_filenames.nil? ? nil : urls_filenames.map { |uf| uf[:name] }
  end

  #saves a video using DownloadHelper. returns true if no errors occured or false otherwise.
  def self.save_file(file_uri, file_name, path = Dir.getwd, amount_of_tries = 1)
    DownloadHelper.save_file(file_uri, file_name, path, amount_of_retries)
  end

  #<<< helper methods >>>

  #the default error message when a plugin fails to download a video.
  def self.plugin_error_message(plugin, error)
    "Error while running the #{plugin.name.inspect} plugin. Maybe it has to be updated?\n"
    "Error: #{error.message}.\n"
    "Backtrace: #{error.backtrace}"
  end
  private_class_method :plugin_error_message

  #takes a url-filenames array and returns a new array where the
  #"location" header has been followed all the way to the end for all urls.
  def self.follow_all_redirects(urls_filenames)
    urls_filenames.map do |uf|
      url = uf[:url]
      final_location = get_final_location(url)
      {:url => final_location, :name => uf[:name]}
    end
  end
  private_class_method :follow_all_redirects

  #recursively get the final location (after following all redirects) for an url.
  def self.get_final_location(url)
    Net::HTTP.get_response(URI(url)) do |res|
      location = res["location"]
      return url if location.nil?
      return get_final_location(location)
    end
  end
  private_class_method :get_final_location
end
