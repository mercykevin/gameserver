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

#兵法进阶预览
#返回概率 值（前端显示直接加个%即可） 和 银币消耗
post '/item/book/advance/pre' do
	requestParams = request[:req_parames]
	player = request[:player]
	id = requestParams[:id]
	result = Model::Item.preAdvance(player[:playerId],id)
	result.to_json
end

#兵法进阶
#返回进阶后的兵法信息，是否成功
#进阶失败的获得的碎片就补给前端了，夺宝列表会重新获取数据
post '/item/book/advance' do
	requestParams = request[:req_parames]
	player = request[:player]
	id = requestParams[:id]
	result = Model::Item.advance(player[:playerId],id)
	itemList.to_json
end









