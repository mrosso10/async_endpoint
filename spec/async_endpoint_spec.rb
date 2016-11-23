require "spec_helper"

describe AsyncEndpoint do
  describe '#configure' do
    before do
      AsyncEndpoint.configure do |config|
        config.cosas = 3
      end
    end

    it do
      async = AsyncEndpoint::AsyncRequest

    end
  end
end