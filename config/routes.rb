Rails.application.routes.draw do

  resources :bus_routes, only: [:index, :show] do
    member do 
      get 'routes/:route_id', to: 'bus_routes#route_show', as: 'route'
    end
  end

  namespace :watched_routes do
    post '/get',    to: 'watched_routes#get'
    post '/add',    to: 'watched_routes#create'
    delete '/remove', to: 'watched_routes#destroy'
  end

end
