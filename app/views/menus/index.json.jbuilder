json.array!(@menus) do |menu|
  json.extract! menu, :id, :mechant_id, :date
  json.url menu_url(menu, format: :json)
end
