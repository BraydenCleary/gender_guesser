GenderGuesser::Application.routes.draw do

  get "/" => "pages#home"

  post "/" => "people#create"

  put "/people/:id" => "people#update"
end
