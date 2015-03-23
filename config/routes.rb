Hydranorth::Application.routes.draw do
  
  blacklight_for :catalog
  devise_for :users

  Hydra::BatchEdit.add_routes(self)

  # Administrative URLs
  namespace :admin do
    # Job monitoring
    constraints Sufia::ResqueAdmin do
      mount Resque::Server, at: 'queues'
    end
  end

  mount BrowseEverything::Engine => '/browse'
  mount Hydra::Collections::Engine => '/'
  mount Sufia::Engine => '/'
  mount HydraEditor::Engine => '/'

  get 'users/:id/lock_access' => 'users#lock_access', as: 'lock_access_user'
  get 'users/:id/unlock_access' => 'users#unlock_access', as: 'unlock_access_user'

  root to: "homepage#index"
  
  # Routes for user's files, collections, highlights and shares
  # Preserves existing behavior by maintaining paths to /dashboard
  # Routes actions to the various My controllers
  scope :dashboard do
    get '/files',             controller: 'my/files', action: :index, as: 'dashboard_files'
    get '/files/page/:page',  controller: 'my/files', action: :index
    get '/files/facet/:id',   controller: 'my/files', action: :facet, as: 'dashboard_files_facet'

    get '/all',             controller: 'my/all', action: :index, as: 'dashboard_all'
    get '/all/page/:page',  controller: 'my/all', action: :index
    get '/all/facet/:id',   controller: 'my/all', action: :facet, as: 'dashboard_all_facet'
    
    get '/collections',             controller: 'my/collections', action: :index, as: 'dashboard_collections'
    get '/collections/page/:page',  controller: 'my/collections', action: :index
    get '/collections/facet/:id',   controller: 'my/collections', action: :facet, as: 'dashboard_collections_facet'

    get '/highlights',            controller: 'my/highlights', action: :index, as: 'dashboard_highlights'
    get '/highlights/page/:page', controller: 'my/highlights', action: :index
    get '/highlights/facet/:id',  controller: 'my/highlights', action: :facet, as: 'dashboard_highlights_facet'

    get '/shares',            controller: 'my/shares', action: :index, as: 'dashboard_shares'
    get '/shares/page/:page', controller: 'my/shares', action: :index
    get '/shares/facet/:id',  controller: 'my/shares', action: :facet, as: 'dashboard_shares_facet'
  end
end
