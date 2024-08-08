Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/swagger' if defined? Rswag
  mount Rswag::Api::Engine => '/swagger' if defined? Rswag

  namespace :api do
    namespace :v1 do
      scope :bus_routes do
        get '/', to: 'bus_routes#index'
        get '/:city', to: 'bus_routes#show'
        get '/:city/routes/:route_id', to: 'bus_routes#route_show'
      end
  
      scope :watched_routes do
        post '/get',    to: 'watched_routes#get'
        post '/add',    to: 'watched_routes#create'
        delete '/remove', to: 'watched_routes#destroy'
      end
    end
  end

  get '*path', to: 'application#index', constraints: ->(req) { !req.xhr? && req.format.html? }
end
