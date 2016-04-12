json.array!(@stores) do |store|
  json.extract! store, :id
  json.url store_url(store, format: :json)
end
