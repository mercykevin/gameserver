#战役列表
post '/battle/list' do
	player = request[:player]
	ret = Model::Battle.getBattleList
	ret.to_json
end

#战役子列表
post '/battle/sublist' do

end

#推图pve
post '/battle/pve' do
	player = request[:player]
	battleId = request[:req_parames][:battleid]
	ret = Model::Battle.pve(battleId,player[:playerId])
	ret.to_json
end



