Kabuofx::Application.routes.draw do
  get "downloads" => "downloads#index"
  get "downloads/ofx" => "downloads#ofx"

  resources :stocks, :only => [:index]

  root 'downloads#index'
end
