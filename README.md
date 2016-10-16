# Async Endpoint

## Summary

This functionality handles the problem of making requests to external API's inside controller
endpoints.

## Approach

To avoid making the external requests inside our endpoints we dellegate this task to a sidekiq
worker and later we have to check periodically the status of the sidekiq job until it is completed.

The flow goes like this:

1. We make an AJAX request
2. The endpoint enqueues a Sidekiq job that executes the request to the external API. Then returns
the `async_request_id` with "202 Accepted" HTTP status. For security reasons it also returns an `async_request_token`, that it's actually the Sidekiq job ID.
3. We wait some time and make another AJAX request but this time sending the `async_request_id` by parameter and the `async_request_token`.
4. The endpoint checks the status of the Sidekiq job. If it is completed returns with HTTP 200
status code. If it is not, returns again with "202 Accepted" HTTP status and we go back to step 3.


## Usage

First we need to define a class that inherits from AsyncRequest and implements the `execute_task` 
method. Here we will make the request to the external API. We can use parameters set in the 
controller endpoint and we need to set the response data using setter methods.

```ruby
class MyAsyncRequest < AsyncRequest
  def execute_task
    @response = execute_external_request(params_hash[:param_1], params_hash[:param_2])
    if @response.present?
      self.some_data = @response['some_data']
      self.another_data = @response['another_data']
      done
    else
      failed 'My custom error message'
    end
  end
end
```

In the controller endpoint we create an instance of our previously defined class. We can pass 
parameters that can be used when the external request is made. Then we define two procs to handle
both successful and failed state.

```ruby
class MyController < ActionController::Base
  def my_endpoint
    @async_request = MyAsyncRequest.init(self, {param_1: 'value_1', param_2: 'value_2'})
    done_proc = proc do
      render json: { some_data: @async_request.some_data,
                     another_data: @async_request.another_data }
    end
    failed_proc = proc do
      render json: { error: @async_request.error_message }
    end
    @async_request.handle(done_proc, failed_proc)
  end
end
```

The only thing left is the javascript code. To start an async request we simply use the
`$.getAsyncRequest` method instead of the regular `$.get` method.

```javascript
  $.getAsyncRequest(url, optional_timeout_in_milliseconds)
  .success(function(response) {
    // Do some work
  }).error(function(response) {
    // Handle error
  });
```

As you can see, the only difference with the regular `$.get` method is that you can pass an optional
parameter that is the maximum time to wait for the response. If this time is reached and the request
has not been made the error handler is dispatched.

