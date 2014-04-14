#战役列表
post '/battle/list' do
	ret = {}
	player = request[:player]
	battleList = Model::Battle.getBattleList
	ret[:battlelist] = battleList
	lastBattleId = Model::Battle.getLastBattleId(player[:playerId])
	if lastBattleId
		metaDao = MetaDao.instance
		metaBattle = metaDao.getSubBattleMetaData(lastBattleId)
		ret[:lastbattleid] = metaBattle.battlefirstID
		ret[:lastsubbattleid] = lastBattleId
	end
	ret.to_json
end

#战役子列表
post '/battle/sublist' do
	ret = {}
	player = request[:player]
	battleId = request[:req_parames][:battleid]
	subBattleList = Model::Battle.getSubBattleList(battleId, player[:playerId])
	lastBattleId = Model::Battle.getLastBattleId(player[:playerId])
	if lastBattleId
		ret[:lastsubbattleid] = lastBattleId
	end
	ret[:subbattlelist] = subBattleList
	ret.to_json
end

#推图pve
post '/battle/pve' do
	player = request[:player]
	subBattleId = request[:req_parames][:subbattleid]
	ret = Model::Battle.pve(subBattleId,player[:playerId])
	ret.to_json
end



