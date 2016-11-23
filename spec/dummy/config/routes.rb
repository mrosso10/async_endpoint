Rails.application.routes.draw do

  mount AsyncEndpoint::Engine => "/async_endpoint"
end
