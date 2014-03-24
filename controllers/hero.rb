#英雄招募
post '/hero/recruite' do
	player = request[:player]
	metaheroid = request[:req_parames][:metaheroid]
	recruitetype = request[:req_parames][:recruitetype]
	ret = Model::Hero.recuritHero(metaheroid,player,recruitetype)
	ret.to_json
end

#创建主英雄
post '/hero/register' do
	requestParams = request[:req_parames]
	player = request[:player]
	templetHeroId = requestParams[:metaheroid]
	ret = Model::Hero.registerMainHero(templetHeroId, player)
	ret.to_json
end

#取上阵中的英雄列表
post '/hero/list' do
	player = request[:player]
	herolist = Model::Hero.getBattleHeroList(player[:playerId])
	herolist.to_json
end

#取空闲的英雄列表
post '/hero/freelist' do
	player = request[:player]
	herolist = Model::Hero.getHeroList(player[:playerId])
	herolist.to_json
end

post '/hero/trans' do
	player = request[:player]
	battleHeroId = request[:req_parames][:battleheroid]
	freeHeroId = request[:req_parames][:freeheroid]
	ret = Model::Hero.transHero(battleHeroId, freeHeroId ,player)
end



