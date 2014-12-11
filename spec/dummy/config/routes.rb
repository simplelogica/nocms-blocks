Rails.application.routes.draw do

  root to: 'home#show'
  mount NoCms::Blocks::Engine => "/nocms-blocks"
end
