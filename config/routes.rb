Kabuofx::Application.routes.draw do
  get "downloads" => "downloads#index"
  get "downloads/ofx" => "downloads#ofx"
  get "downloads/codes" => "downloads#codes"

  resources :stocks, :only => [:index]

  root 'downloads#index'
end
