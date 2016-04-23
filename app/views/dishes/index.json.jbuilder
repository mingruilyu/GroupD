json.array!(@dishes) do |dish|
  json.extract! dish, :id, : name, :price, :image_url, :desc, :count, :merchant_id
  json.url dish_url(dish, format: :json)
end
