# This class contains utility methods that are used by both the bin utility and the library.

module ViddlRb

  class UtilityHelper
    #loads all plugins in the plugin directory.
    #the plugin classes are dynamically added to the ViddlRb module.
    def self.load_plugins
      Dir[File.join(File.dirname(__FILE__), "../plugins/*.rb")].each do |plugin|
        ViddlRb.class_eval(File.read(plugin))
      end
    end

    #checks to see whether the os has a certain utility like wget or curl
    #`` returns the standard output of the process
    #system returns the exit code of the process
    def self.os_has?(utility)
      windows = ENV['OS'] =~ /windows/i

      unless windows
        `which #{utility}`.include?(utility.to_s)
      else
        if !system("where /q where").nil?   #if Windows has the where utility
          system("where /q #{utility}")     #/q is the quiet mode flag
        else
          begin                             #as a fallback we just run the utility itself
            system(utility)
          rescue Errno::ENOENT
            false
          end
        end
      end
    end

    #recursively get the final location (after following all redirects) for an url.
    def self.get_final_location(url)
      Net::HTTP.get_response(URI(url)) do |res|
        location = res["location"]
        return url if location.nil?
        return get_final_location(location)
      end
    end

  end
end
