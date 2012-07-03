class PluginBase
  #some static stuff
  class << self; attr_reader :registered_plugins end
    @registered_plugins = []

  #if you inherit from this class, the child gets added to the "registered plugins" array
  def self.inherited(child)
    PluginBase.registered_plugins << child
  end

  #takes a string a returns a new string that is file name safe
  #deletes \"' and replaces anything else that is not a digit or letter with _
  def self.make_filename_safe(string)
    string.delete("\"'").gsub(/[^\d\w]/, '_')
  end
end
