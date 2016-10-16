module AsyncEndpoint
  class AsyncEndpointWorker
    include Sidekiq::Worker

    def perform(async_request_id)
      async_request = AsyncRequest.find(async_request_id)
      async_request.execute
    end
  end
end
