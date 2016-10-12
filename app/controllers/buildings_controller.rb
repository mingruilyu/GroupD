class BuildingsController < ApplicationController

  def query_by_city_company
    buildings = Building.by_city_company @city.id, @company.id
    render json: Response::JsonResponse.new(buildings)
  end

  def fuzzy_query_by_address_name
    buildings = Building.by_address_name @query
    render json: Response::JsonResponse.new(buildings)
  end

  def query_by_coord
    buildings = Building.by_coordinate @lat, @lng, 
      Location::BUILDING_COORDINATE_RESOLUTAION 
    render json: Response::JsonResponse.new(buildings)
  end

  private

    def params_sanitization
      sanitize :query_by_city_company, city_id: :city, company_id: :company
      sanitize :fuzzy_query_by_address_name, query: :query
      sanitize :query_by_coord, lat: :coordinate, lng: :coordinate
    end

end
