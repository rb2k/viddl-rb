class PluginBase
#some static stuff
  class << self; attr_reader :registered_plugins end
    @registered_plugins = []

#if you inherit from this class, the child gets added to the "registered plugins" array
  def self.inherited(child)
    PluginBase.registered_plugins << child
  end
end
