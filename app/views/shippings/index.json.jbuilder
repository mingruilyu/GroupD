json.array!(@shippings) do |shipping|
  json.extract! shipping, :id
  json.url shipping_url(shipping, format: :json)
end
