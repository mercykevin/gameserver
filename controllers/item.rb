#已装备列表
post '/item/used/list' do
	requestParams = request[:req_parames]
	player = request[:player]
	sort = requestParams[:sort]
	itemList = Model::Item.getEquipUnusedList(player[:playerId],sort)
	itemList.to_json
end

#强化装备
post '/item/equip/strengthen' do
	requestParams = request[:req_parames]
	player = request[:player]
	id = requestParams[:id]
	itemList = Model::Item.strengthen(player[:playerId],id)
	itemList.to_json
end








