require 'sinatra'
require 'json'

sample = {
  '2015-04-01' => 198, '2015-04-02' => 197.6, '2015-04-03' => 197,
  '2015-04-04' => 198, '2015-04-05' => 196.6, '2015-04-06' => 196,
  '2015-04-07' => 195.8, '2015-04-08' => 196.2, '2015-04-09' => 195.2
  }


get '/' do
  [200, 'Hello']
end

get '/weight' do
  content_type :json
  sample.to_json
end

post '/weight' do
  p params
  [201, params[:wgt]]
end