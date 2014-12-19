require "ep_postmaster/engine"
require "ep_postmaster/configuration"
require "ep_postmaster/errors/parameter_missing"
require "ep_postmaster/errors/wrong_endpoint_error"

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
