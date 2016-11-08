class LocationsController < WebApplicationController

  def query
    map_response = Services::GoogleMap.location_query @query
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
