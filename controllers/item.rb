#已装备列表
post '/item/used/list' do
	requestParams = request[:req_parames]
	player = request[:player]
	sort = requestParams[:sort]
	itemList = Model::Item.getEquipUnusedList(player[:playerId],sort)
	itemList.to_json

end








