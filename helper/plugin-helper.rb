class PluginBase
  def self.inherited(child)
    # register child somewhere
    # just to give a complete example:
    PluginBase.registered_plugins << child
  end
  @registered_plugins = []
  class << self; attr_reader :registered_plugins end
end
