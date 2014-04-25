
require 'shellwords'

module ViddlRb

  # This class contains utility methods that are used by both the bin utility and the library.
  class UtilityHelper

    # Loads all plugins in the plugin directory.
    # The plugin classes are dynamically added to the ViddlRb module.
    # A plugin can have helper classes. These classes must exist in a in directory under the
    # plugins directory that has the same name as the plugin filename wihouth the .rb extension.
    # All classes found in such a directory will dynamically added as inner classes of the
    # plugin class.
    def self.load_plugins
      plugins_dir  = File.join(File.dirname(__FILE__), "../plugins")
      plugin_paths = Dir[File.join(plugins_dir, "*.rb")]

      plugin_paths.each do |path|
        filename = File.basename(path, File.extname(path))
        plugin_code = File.read(path)
        class_name = plugin_code[/class (\w+) < PluginBase/, 1]
        components = Dir[File.join(plugins_dir, filename, "*.rb")]

        ViddlRb.class_eval(plugin_code)

        components.each do |component|
          code = File.read(component)
          ViddlRb.const_get(class_name).class_eval(code)
        end
      end
    end

    def self.windows?
      (RbConfig::CONFIG["host_os"] =~ /windows|mingw/i) != nil
    end

    def self.jruby?
      ENV["RUBY_VERSION"] != nil && ENV["RUBY_VERSION"].downcase.include?("jruby")
    end

    def self.make_shellsafe_path(path)
      # JRuby cannot open some paths that are escaped with Shellwords.escape so this is a workaround.
      if jruby?
        '"' + path + '"'
      else
        Shellwords.escape(path)
      end
    end

    def self.base_path
      File.join(File.dirname(File.expand_path(__FILE__)), "..")
    end

    # checks to see whether the os has a certain utility like wget or curl
    # `` returns the standard output of the process
    # system returns the exit code of the process
    def self.os_has?(utility)
      if windows?
        if !system("where /q where").nil?   #if Windows has the where utility
          system("where /q #{utility}")     #/q is the quiet mode flag
        else
          begin #as a fallback we just run the utility itself
            system(utility)
          rescue Errno::ENOENT
            false
          end
        end
      else
        # This might work in windows too... I am not quite sure :-/
        ENV['PATH'].split(':').any?{|dir| File.exist?( File.join(dir, utility.to_s) ) }
      end
    end

    # recursively get the final location (after following all redirects)
    # for an url.
    def self.get_final_location(url)
      Net::HTTP.get_response(URI.parse(url)) do |res|
        location = res["location"]
        return url if location.nil?
        return get_final_location(location)
      end
    end

  end
end
