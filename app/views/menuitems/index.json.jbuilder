json.array!(@menuitems) do |menuitem|
  json.extract! menuitem, :id, :dish_id, :menu_id
  json.url menuitem_url(menuitem, format: :json)
end
