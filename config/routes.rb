Rails.application.routes.draw do
  resources :comments, :controller => 'muck/comments'
end
