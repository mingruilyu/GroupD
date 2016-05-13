json.array!(@restaurants) do |restaurant|
  json.extract! restaurant, :id
  json.url restaurant_url(restaurant, format: :json)
end
