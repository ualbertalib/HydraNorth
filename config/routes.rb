require 'resque/server'

Hydranorth::Application.routes.draw do
  get 'recent/index'

  namespace :admin do
    get 'become/index'
  end

  blacklight_for :catalog
  devise_for :users, :controllers => { :sessions => 'users/sessions',:omniauth_callbacks => "users/omniauth_callbacks" }

  Hydra::BatchEdit.add_routes(self)

   # Administrative URLs
   namespace :admin do
    # Job monitoring
    constraints Sufia::ResqueAdmin do
      mount Resque::Server, at: '/queues'
    end
  end

  mount BrowseEverything::Engine => '/browse_everything'
  mount Hydra::Collections::Engine => '/'
  mount HydraEditor::Engine => '/'

  get 'users/:id/lock_access' => 'users#lock_access', as: 'lock_access_user'
  get 'users/:id/unlock_access' => 'users#unlock_access', as: 'unlock_access_user'

  get 'users/:id/link_account' => 'users#link_account', as: 'link_account_user'
  get 'users/:id/set_saml' => 'users#set_saml', as: 'set_saml_user'

  # redirect ERA AV to Avalon server
  get '/av' => 'redirect#era_av'

  # redirect old item url to hydranorth
  get '/public/view/item/:uuid' => 'redirect#item'
  get '/public/view/item/:uuid/:ds' => 'redirect#datastream'
  get '/public/view/item/:uuid/:ds/*file' => 'redirect#datastream', format: false
  get '/public/datastream/get/:uuid/:ds' => 'redirect#datastream'
  get '/public/datastream/get/:uuid/:ds/*file' => 'redirect#datastream', format: false
  get '/public/view/collection/:uuid' => 'redirect#collection'
  get '/public/view/community/:uuid' => 'redirect#collection'
  get '/public/view/author/:username' => 'redirect#author'
  get '/action/submit/init/thesis/:uuid' => 'redirect#thesis'
  get '/downloads/:id' => 'redirect#sufiadownload'

  scope :dashboard do

    get '/files',             controller: 'my/files', action: :index, as: 'dashboard_files'
    get '/files/page/:page',  controller: 'my/files', action: :index
    get '/files/facet/:id',   controller: 'my/files', action: :facet, as: 'dashboard_files_facet'

    get '/shares',             controller: 'my/shares', action: :index, as: 'dashboard_shares'
    get '/shares/page/:page',  controller: 'my/shares', action: :index
    get '/shares/facet/:id',   controller: 'my/shares', action: :facet, as: 'dashboard_shares_facet'

    get '/collections',             controller: 'my/collections', action: :index, as: 'dashboard_collections'
    get '/collections/page/:page',  controller: 'my/collections', action: :index
    get '/collections/facet/:id',   controller: 'my/collections', action: :facet, as: 'dashboard_collections_facet'

    get '/all',             controller: 'my/all', action: :index, as: 'dashboard_all'
    get '/all/page/:page',  controller: 'my/all', action: :index
    get '/all/facet/:id',   controller: 'my/all', action: :facet, as: 'dashboard_all_facet'

  end


  get 'stats', controller: 'repository_statistics', action: :facet_stats, as: :generic_files_stats

  #get ':action' => 'static#:action', constraints: { action: /help|terms|zotero|mendeley|agreement|subject_libraries|versions/ }, as: :static
  get 'policies' => 'pages#policies', id: 'policies_page'
  get 'technology' => 'pages#technology', id: 'technology_page'
  get 'deposit' => 'pages#deposit', id: 'deposit_page'
  get 'browse',  controller: 'browse', action: :index
  get 'advanced' => 'advanced#index', as: :advanced
  get 'batches/:id/update_collections' => 'batch#update_collections', as: 'update_collections'
  get 'files/:id/stats' => 'generic_files#stats'
  get 'files/:id/edit' => 'generic_files#edit'

# Generic file routes
  resources :generic_files, path: :files, except: [:index, :show] do
    member do
      resource :featured_work, only: [:create, :destroy]
      resources :transfers, as: :generic_file_transfers, only: [:new, :create]
      get 'citation'
      get 'stats'
      post 'audit'
    end
  end

  get 'files/:id/update_collections' => 'generic_files#update_collections'
  get 'communities', controller: 'communities', action: :index
  get 'communities/logo', controller: 'communities', action: :logo
  get 'collections/:id/:sort', controller: 'collections', action: :show
  get 'collections/:id/:per_page', controller: 'collections', action: :show
  get 'collections/:id/edit', controller: 'collections', action: :edit
  get 'recent', controller: 'recent', action: :index

  # TODO needs regression test which shows that Sufia::DownloadsController param[:file]
  # is set correctly for thumbnails
  get 'files/:id/*name' => 'downloads#show'

  get 'public/home', to: redirect('/', status: 301)

  # This must be the very last route in the file because it has a catch-all route for 404 errors.
  # This behavior seems to show up only in production mode.
  mount Sufia::Engine => '/'
  root to: 'homepage#index'
end
