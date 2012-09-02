# This class contains utility methods that are used by both the bin utility and the library.

class UtilityHelper
  #loads all plugins in the plugin directory.
  def self.load_plugins
    Dir[File.join(File.dirname(__FILE__),"../plugins/*.rb")].each do |plugin|
      require plugin
    end
  end
end
