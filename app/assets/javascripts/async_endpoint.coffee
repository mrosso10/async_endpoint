JQueryXHR = ->
  _error = null
  _success = null
  _complete = null
  _arguments = null
  successCallbacks = []
  errorCallbacks = []
  completeCallbacks = []

  @success = (callback) ->
    if _success
      callback.apply this, _arguments
    successCallbacks.push callback
    this

  @error = (callback) ->
    if _error
      callback.apply this, _arguments
    errorCallbacks.push callback
    this

  @complete = (callback) ->
    if _complete
      callback.apply this, _arguments
    completeCallbacks.push callback
    this

  @dispatchSuccess = ->
    `var i`
    _arguments = arguments
    _complete = _success = true
    for i of successCallbacks
      successCallbacks[i].apply this, _arguments
    for i of completeCallbacks
      completeCallbacks[i].apply this, _arguments
    return

  @dispatchError = ->
    `var i`
    _arguments = arguments
    _complete = _success = true
    for i of errorCallbacks
      errorCallbacks[i].apply this, _arguments
    for i of completeCallbacks
      completeCallbacks[i].apply this, _arguments
    return
  return


window.jQuery.getAsyncEndpoint = (url, max_time_to_wait, async_request_id, async_request_token, jqXHR, start_time) ->
  jqXHR = new JQueryXHR() if jqXHR == undefined
  max_time_to_wait = 30000 if max_time_to_wait == undefined
  start_time = Date.now() if start_time == undefined
  time_elapsed = Date.now() - start_time
  $.get(url, 'async_request_id': async_request_id, 'async_request_token': async_request_token)
  .success((response, status, xhr) ->
    if xhr.status == 202
      if time_elapsed < max_time_to_wait
        setTimeout (->
          $.getAsyncEndpoint url, max_time_to_wait, response.async_request_id, response.async_request_token, jqXHR, start_time
        ), time_elapsed * 0.4 + 1000
      else
        jqXHR.dispatchError()
    else
      jqXHR.dispatchSuccess(response, status, xhr)
  ).error( ->
    jqXHR.dispatchError()
  )
  jqXHR
