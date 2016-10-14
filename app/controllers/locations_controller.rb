class LocationsController < ApplicationController

  def query
    map_request = Request::JsonRequest.new ENV['GOOGLE_MAP_URL'], 
        'test/fixtures/map_response', query: @query, 
        key: ENV['GOOGLE_MAP_KEY']
    map_response = map_request.get
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
