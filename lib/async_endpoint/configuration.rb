module AsyncEndpoint
  class Configuration
    attr_accessor :error_handlers

    def initialize
      @error_handlers = []
    end
  end
end
