Rails.application.routes.draw do
  namespace :api do
  	api_version(module: 'V1', path: { value: 'v1' }, default: true,
  							defaults: { format: 'json' }) do
  		resources :tasks
  		resources :tags
  	end
  end
end
