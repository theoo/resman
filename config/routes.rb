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
  resources :comments do
    collection do
      post :ajax_comment_read
    end
  end
  resources :continents
  resources :countries
  resources :groups do
    member do
      get :manage_rights
      post :update_rights
    end
  end
  resources :invoices do
    resources :items
    resources :incomes
    resources :comments
    resources :activities

    collection do
      get :confirm, :send_pdf, :export_all
      post :generate, :ajax_invoice_closed
    end
  end
  resources :incomes do
    collection do
      post :confirm, :generate
      get :export_all
    end
  end
  resources :institutes
  resources :rates do
    resources :rooms
    resources :rules
  end
  resources :religions
  resources :reservations do
    collection do
      get 'planning'
    end
    resources :reservation_options, as: :options
  end
  resources :residents, collection: { export_all: :get }, member: { export: :get }
  resources :rooms do
    resources :reservations
    resources :comments
    resources :activities
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
