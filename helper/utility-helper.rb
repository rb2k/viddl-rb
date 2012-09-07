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
  end

end

