Kabuofx::Application.routes.draw do
  get "downloads/index"

  resources :stocks, :only => [:index]

  root 'downloads#index'
end
