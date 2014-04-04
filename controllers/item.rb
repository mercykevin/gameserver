#已装备列表
post '/item/used/list' do
	requestParams = request[:req_parames]
	player = request[:player]
	sort = requestParams[:sort]
	itemList = Model::Item.getEquipUnusedList(player[:playerId],sort)
	itemList.to_json
end

#装备强化
#返回强化后的装备信息
#是否暴击，下次强化银币消耗，前端自己计算
post '/item/equip/strengthen' do
	requestParams = request[:req_parames]
	player = request[:player]
	id = requestParams[:id]
	itemList = Model::Item.strengthen(player[:playerId],id)
	itemList.to_json
end

#兵法进阶
#返回进阶后的兵法信息
#
post '/item/book/advance' do
	requestParams = request[:req_parames]
	player = request[:player]
	id = requestParams[:id]
	itemList = Model::Item.advance(player[:playerId],id)
	itemList.to_json
end









