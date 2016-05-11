json.array!(@cellphones) do |cellphone|
  json.extract! cellphone, :id
  json.url cellphone_url(cellphone, format: :json)
end
