# user@tovan nov_rp (master)$ rake routes
#                  Prefix Verb   URI Pattern                                    Controller#Action
#                   token POST   /token(.:format)                               tokens#create
#            scim_clients POST   /scim/clients(.:format)                        scim/clients#create
#              scim_users GET    /scim/users(.:format)                          scim/users#index
#                         POST   /scim/users(.:format)                          scim/users#create
#               scim_user PATCH  /scim/users/:id(.:format)                      scim/users#update
#                         PUT    /scim/users/:id(.:format)                      scim/users#update
#                         DELETE /scim/users/:id(.:format)                      scim/users#destroy
#               contracts POST   /contracts(.:format)                           contracts#create
#                         PUT    /contracts(.:format)                           contracts#update
#                         DELETE /contracts(.:format)                           contracts#destroy
# callback_tenant_session GET    /tenants/:tenant_id/session/callback(.:format) tenants/sessions#create
#          tenant_session GET    /tenants/:tenant_id/session(.:format)          tenants/sessions#show
#                 session DELETE /session(.:format)                             sessions#destroy
#                    root GET    /                                              top#show

Rails.application.routes.draw do
  resource :token, only: :create
  namespace :scim do
    resources :clients, only: :create
    resources :users, only: [:index, :create, :update, :destroy]
  end
  post   :contracts, to: 'contracts#create'
  put    :contracts, to: 'contracts#update'
  delete :contracts, to: 'contracts#destroy'

  resources :tenants, only: [], module: :tenants do
    resource :session, only: :show do
      get :callback, to: 'sessions#create'
    end
  end
  resource :session, only: :destroy

  root 'top#show'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
