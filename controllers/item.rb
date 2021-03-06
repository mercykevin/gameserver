#未装备列表
post '/item/unused/list' do
	requestParams = request[:req_parames]
	player = request[:player]
	sort = requestParams[:sort]
	itemList = Model::Item.getEquipUnusedList(player[:playerId],sort)
	itemList.to_json
end

#已装备列表
#返回 装备信息，可激活武将名，谁装备的，不可强化的原因
post '/item/used/list' do
	itemList = []
	itemList.to_json
end

#装备强化
#返回强化后的装备信息
#是否暴击，下次强化银币消耗，前端自己计算
post '/item/equip/strengthen' do
	requestParams = request[:req_parames]
	player = request[:player]
	id = requestParams[:id]
	ret = Model::Item.strengthenEquip(player,id)
	ret.to_json
end

#兵法进阶，一键选择
post '/item/book/advance/auto/choose' do
	player = request[:player]
	result = Model::Item.autoChooseBooks(player[:playerId])
	result.to_json
end


#兵法进阶预览
#返回概率 值（前端显示直接加个%即可） 和 银币消耗
post '/item/book/advance/pre' do
	requestParams = request[:req_parames]
	player = request[:player]
	id = requestParams[:id]
	srcIds = requestParams[:srcIds]
	result = Model::Item.preAdvanceBookService(player,id ,srcIds)
	result.to_json
end

#兵法进阶
#返回进阶后的兵法信息，是否成功
#进阶失败的获得的碎片就补给前端了，夺宝列表会重新获取数据
#srcIds：逗号分隔的兵法id
post '/item/book/advance' do
	requestParams = request[:req_parames]
	player = request[:player]
	id = requestParams[:id]
	srcIds = requestParams[:srcIds]
	result = Model::Item.advanceBook(player,id , srcIds)
	result.to_json
end

#扩展背包
#每次固定增加N个格子
post '/item/backpack/cell/extend' do
	player = request[:player]
	sort = requestParams[:sort]
	result = Model::Item.extendPackCell(player,sort)
	result.to_json
end










