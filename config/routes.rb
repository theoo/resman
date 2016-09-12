Rails.application.routes.draw do

  resources :activities
  resources :attachments, except: [:index]
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
      get 'planning',
        'ajax_room_options',
        'ajax_room_availables'
      post :search
    end
    resources :reservation_options, as: :options
  end
  resources :residents do
    member do
      get :export
    end
    collection do
      get :export_all, :autocomplete_name
    end
  end

  resources :rooms do
    resources :reservations
    resources :comments
    resources :activities
    resources :room_options, as: :options
    # collection do
    #   get :autocomplete_name
    # end
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
