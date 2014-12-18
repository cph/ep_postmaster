require "ep_postmaster/engine"
require "ep_postmaster/configuration"

module EpPostmaster
  
  class << self
    
    def configuration
      @configuration ||= Configuration.new
    end
    
  end

  def self.configure
    yield(self.configuration)
  end
  
end
