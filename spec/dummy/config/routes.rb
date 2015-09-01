Rails.application.routes.draw do

  root to: 'home#show'
  resources :slotted_pages, only: [:show]

  mount NoCms::Blocks::Engine => "/nocms-blocks"
end
