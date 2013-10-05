#!/usr/bin/env ruby
$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'helper')

require "rubygems"
require "net/http"
require "nokogiri"
require "multi_json"
require "mechanize"
require "cgi"
require "open-uri"
require "stringio"
require "download-helper.rb"
require "plugin-helper.rb"
require "utility-helper.rb"

#load all plugins
ViddlRb::UtilityHelper.load_plugins

module ViddlRb
  class PluginError < StandardError; end
  class DownloadError < StandardError; end

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
  def self.get_urls_names(url)
    plugin = PluginBase.registered_plugins.find { |p| p.matches_provider?(url) }

    if plugin 
      begin
        #we'll end up with an array of hashes with they keys :url and :name
        urls_filenames = plugin.get_urls_and_filenames(url)
      rescue PluginBase::CouldNotDownloadVideoError => e
        raise_download_error(e)
      rescue StandardError => e
        raise_plugin_error(e, plugin)
      end
      follow_all_redirects(urls_filenames)
    else
      nil
    end
  end

  #returns an array of download urls for the given video url.
  def self.get_urls(url)
    urls_filenames = get_urls_names(url)
    urls_filenames.nil? ? nil : urls_filenames.map { |uf| uf[:url] }
  end

  #returns an array of filenames for the given video url.
  def self.get_names(url)
    urls_filenames = get_urls_names(url)
    urls_filenames.nil? ? nil : urls_filenames.map { |uf| uf[:name] }
  end

  #same as get_urls_and_filenames but with the extensions only.
  def self.get_urls_exts(url)
    urls_filenames = get_urls_names(url)
    urls_filenames.map do |uf|
      ext = File.extname(uf[:name])
      {:url => uf[:url], :ext => ext}
    end
  end

  #<<< helper methods >>>

  #the default error message when a plugin fails in some unexpected way.
  def self.raise_plugin_error(e, plugin)
    error = PluginError.new(e.message + " [Plugin: #{plugin.name}]")
    error.set_backtrace(e.backtrace)
    raise error
  end
  private_class_method :raise_plugin_error

  #the default error message when a plugin fails to download a video for a known reason.
  def self.raise_download_error(e)
    error = DownloadError.new(e.message)
    error.set_backtrace(e.backtrace)
    raise error
  end
  private_class_method :raise_download_error

  #takes a url-filenames array and returns a new array where the
  #"location" header has been followed all the way to the end for all urls.
  def self.follow_all_redirects(urls_filenames)
    urls_filenames.map do |uf|
      url = uf[:url]
      final_location = UtilityHelper.get_final_location(url)
      {:url => final_location, :name => uf[:name]}
    end
  end
  private_class_method :follow_all_redirects
end
