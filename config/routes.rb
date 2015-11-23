Rails.application.routes.draw do

  # Autocomplete (http://codeintensity.blogspot.com/2008/02/auto-complete-text-fields-in-rails-2.html)
  # auto_complete ':controller/:action',
  #                   :requirements => { :action => /auto_complete_for_\S+/ },
  #                   :conditions => { :method => :get }

  # Ajax
  # ajax          ':controller/:action',
  #                   :requirements => { :action => /ajax_\S+/ },
  #                   :conditions => { :method => :get }

  # Resources
  resources :activities
  resources :buildings
  resources :comments, collection: { ajax_comment_read: :post }
  resources :continents
  resources :countries
  resources :groups, member: { manage_rights: :get, update_rights: :post }
  resources :invoices, has_many: [:items, :incomes, :comments, :activities], collection: { confirm: :get, generate: :post, send_pdf: :get, export_all: :get, ajax_invoice_closed: :post }
  resources :incomes, collection: { confirm: :post, generate: :post, export_all: :get }
  resources :institutes
  resources :rates, has_many: [:rooms, :rules]
  resources :religions
  resources :reservations do
    collection do
      get 'planning'
    end
    resources :reservation_options, as: :options
  end
  resources :residents, collection: { export_all: :get }, member: { export: :get }
  resources :rooms, has_many: [:reservations, :comments, :activities] do
    resources :room_options, as: :options
  end
  resources :room_options
  resources :rules
  resources :schools
  resources :users
  resources :options
  resources :overview do
    collection do
      get 'summary', 'statistics', 'preferences', 'inout', 'residents'
    end
  end

  # Authentication
  get 'login', to: 'sessions#new'
  get 'logout', to: 'sessions#destroy'
  get 'denied', to: 'sessions#denied'
  resources :sessions

  # Root
  root "overview#index"
end
