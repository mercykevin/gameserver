#未装备列表
post '/item/unused/list' do
	requestParams = request[:req_parames]
	player = request[:player]
	itemList = Model::Item.getItemUnusedList(player[:playerId])
	itemList.to_json
 
end

#已装备列表
post '/item/used/list' do
	requestParams = request[:req_parames]
	player = request[:player]
	sort = requestParams[:sort]
	itemList = Model::Item.getItemUsedList(player[:playerId],sort)
	itemList.to_json

end








