require 'sinatra'

get '/' do
  [200, 'Hello']
end

post '/weight' do
  p params
  [201, params[:wgt]]
end