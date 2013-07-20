Kabuofx::Application.routes.draw do
  get "downloads" => "downloads#index"

  resources :stocks, :only => [:index]

  root 'downloads#index'
end
