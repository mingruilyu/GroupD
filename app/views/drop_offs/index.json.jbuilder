json.array!(@drop_offs) do |drop_off|
  json.extract! drop_off, :id
  json.url drop_off_url(drop_off, format: :json)
end
