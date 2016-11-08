class CompaniesController < WebApplicationController
  def index
    companies = Company.by_city @city.id
    render json: Response::JsonResponse.new(companies)
  end

  def query
    companies = Company.fuzzy_by_name @name
    render json: Response::JsonResponse.new(companies)
  end

  private
    def params_sanitization
      sanitize :index, city_id: :city
      sanitize :query, name: :query
    end
end
