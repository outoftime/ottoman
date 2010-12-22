class Article < Ottoman::Document
  property :title
  property :body
  property :author_username, :view => true

  resource :publication
  resources :comments
end
