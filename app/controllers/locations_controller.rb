class LocationsController < ApplicationController

  def query
    if ENV['RAILS_ENV'] == 'test'
      puts 'RUNNING SIMULATED REQUEST...'
      simulation = Request::Simulation.new 'test/map_response'
      map_response = simulation.run 
    else
      puts 'REQUESTING FROM GOOGLE MAP SERVICE....'
      map_request = Request::JsonRequest.new ENV['GOOGLE_MAP_URL'], 
        query: @query, key: ENV['GOOGLE_MAP_KEY']
      map_response = map_request.get
    end
    json = JSON.parse(map_response)
    locations = []
    json['results'].each do |place|
      locations.append(Location.from_json place)
    end
    render json: Response::JsonResponse.new(locations)
  end

  private

    def params_sanitization
      sanitize :query, query: :query
    end
end
