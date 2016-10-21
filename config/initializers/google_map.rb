Services::GoogleMap.setup do |config|
  config.use_simulation = (ENV['RAILS_ENV'] == 'test')
  config.api_key = ENV['GOOGLE_MAP_KEY']
  config.api_uri = 'https://maps.googleapis.com/maps/api/place/textsearch/json'
  config.simulation_uri = 'test/fixtures/map_response'
end
