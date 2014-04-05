Rails.application.routes.draw do

  mount NoCms::Blocks::Engine => "/nocms-blocks"
end
