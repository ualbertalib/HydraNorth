Hydranorth::Application.routes.draw do
  
  blacklight_for :catalog
  devise_for :users, :controllers => { :sessions => 'users/sessions',:omniauth_callbacks => "users/omniauth_callbacks" }

  Hydra::BatchEdit.add_routes(self)

  # Administrative URLs
  namespace :admin do
    # Job monitoring
    constraints Sufia::ResqueAdmin do
      mount Resque::Server, at: 'queues'
    end
  end

  mount BrowseEverything::Engine => '/browse_everything'  
  mount Hydra::Collections::Engine => '/'
  mount HydraEditor::Engine => '/'

  get 'users/:id/lock_access' => 'users#lock_access', as: 'lock_access_user'
  get 'users/:id/unlock_access' => 'users#unlock_access', as: 'unlock_access_user'

  get 'users/:id/link_account' => 'users#link_account', as: 'link_account_user'
  get 'users/:id/set_saml' => 'users#set_saml', as: 'set_saml_user'

  scope :dashboard do

    get '/files',             controller: 'my/files', action: :index, as: 'dashboard_files'
    get '/files/page/:page',  controller: 'my/files', action: :index
    get '/files/facet/:id',   controller: 'my/files', action: :facet, as: 'dashboard_files_facet'

    get '/collections',             controller: 'my/collections', action: :index, as: 'dashboard_collections'
    get '/collections/page/:page',  controller: 'my/collections', action: :index
    get '/collections/facet/:id',   controller: 'my/collections', action: :facet, as: 'dashboard_collections_facet'

    get '/all',             controller: 'my/all', action: :index, as: 'dashboard_all'
    get '/all/page/:page',  controller: 'my/all', action: :index
    get '/all/facet/:id',   controller: 'my/all', action: :facet, as: 'dashboard_all_facet'
    
  end

  get '/browse',  controller: 'browse', action: :index
  get 'advanced' => 'advanced#index', as: :advanced

  # This must be the very last route in the file because it has a catch-all route for 404 errors.
  # This behavior seems to show up only in production mode.
  mount Sufia::Engine => '/'
  root to: 'homepage#index'
end
