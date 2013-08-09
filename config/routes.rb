Kabuofx::Application.routes.draw do
  get "downloads" => "downloads#index"
  get "downloads/ofx" => "downloads#ofx"
  get "downloads/codes" => "downloads#codes"

  resources :stocks, :only => [:index]
  get "stocks/names/:codes" => "stocks#names"

  root 'downloads#index'
end
