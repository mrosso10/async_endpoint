JQueryXHR = ->
  _fail = null
  _done = null
  _always = null
  _arguments = null
  doneCallbacks = []
  failCallbacks = []
  alwaysCallbacks = []

  @done = (callback) ->
    if _done
      callback.apply this, _arguments
    doneCallbacks.push callback
    this

  @fail = (callback) ->
    if _fail
      callback.apply this, _arguments
    failCallbacks.push callback
    this

  @always = (callback) ->
    if _always
      callback.apply this, _arguments
    alwaysCallbacks.push callback
    this

  @dispatchDone = ->
    `var i`
    _arguments = arguments
    _always = _done = true
    for i of doneCallbacks
      doneCallbacks[i].apply this, _arguments
    for i of alwaysCallbacks
      alwaysCallbacks[i].apply this, _arguments
    return

  @dispatchFail = ->
    `var i`
    _arguments = arguments
    _always = _done = true
    for i of failCallbacks
      failCallbacks[i].apply this, _arguments
    for i of alwaysCallbacks
      alwaysCallbacks[i].apply this, _arguments
    return
  return


window.jQuery.getAsyncEndpoint = (url, max_time_to_wait, async_request_id, async_request_token, jqXHR, start_time) ->
  jqXHR = new JQueryXHR() if jqXHR == undefined
  max_time_to_wait = 30000 if max_time_to_wait == undefined
  start_time = Date.now() if start_time == undefined
  time_elapsed = Date.now() - start_time
  $.get(url, 'async_request_id': async_request_id, 'async_request_token': async_request_token)
  .done((response, status, xhr) ->
    if xhr.status == 202
      if time_elapsed < max_time_to_wait
        setTimeout (->
          $.getAsyncEndpoint url, max_time_to_wait, response.async_request_id, response.async_request_token, jqXHR, start_time
        ), time_elapsed * 0.4 + 1000
      else
        jqXHR.dispatchFail(response, status, xhr)
    else
      jqXHR.dispatchDone(response, status, xhr)
  ).fail((response, status, xhr) ->
    jqXHR.dispatchFail(response, status, xhr)
  )
  jqXHR
