require "async_endpoint/engine"
require "async_endpoint/configuration"

module AsyncEndpoint
  class << self
    attr_writer :configuration
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield(configuration)
  end
end
