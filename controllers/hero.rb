#英雄招募冷却时间显示
post '/hero/prerecruite' do
	ret = {:lefttime1 => 0, :lefttime2 => 0, :lefttime3 => 0}
	player = request[:player]
	recruiteInfo = Model::Hero.getHeroRecruiteInfo(player[:playerId])
	metaDao = MetaDao.instance
	if recruiteInfo.key?(:recuritetime1)
		metaData = metaDao.getRecuriteMetaData("普通")
		lefttime = metaData.rFreeCooling.to_i - (Time.now.to_i - recruiteInfo[:recuritetime1])
		ret[:lefttime1] = lefttime unless lefttime < 0
	end
	if recruiteInfo.key?(:recuritetime2)
		metaData = metaDao.getRecuriteMetaData("高级")
		lefttime = metaData.rFreeCooling.to_i - (Time.now.to_i - recruiteInfo[:recuritetime2])
		ret[:lefttime2] = lefttime unless lefttime < 0
	end
	if recruiteInfo.key?(:recuritetime3)
		metaData = metaDao.getRecuriteMetaData("将军令")
		lefttime = metaData.rFreeCooling.to_i - (Time.now.to_i - recruiteInfo[:recuritetime3])
		ret[:lefttime3] = lefttime unless lefttime < 0
	end
	ret.to_json
end

#英雄招募
post '/hero/recruite' do
	player = request[:player]
	recruitetype = request[:req_parames][:recruitetype]
	ret = Model::Hero.recuritHero(player,recruitetype)
	if ret[:retcode] == Const::ErrorCode::Ok
		Model::Hero.setItemData2Hero(ret[:hero], player)
	end
	ret.to_json
end

#创建主英雄
post '/hero/register' do
	requestParams = request[:req_parames]
	player = request[:player]
	templetHeroId = requestParams[:metaheroid]
	ret = Model::Hero.registerMainHero(templetHeroId, player)
	if ret[:retcode] == Const::ErrorCode::Ok
		Model::Hero.setItemData2Hero(ret[:hero], player)
	end	
	ret.to_json
end

#取上阵中的英雄列表
post '/hero/list' do
	player = request[:player]
	herolist = Model::Hero.getBattleHeroList(player[:playerId])
	herolist.each do |hero|
		if hero.class == Hash
			Model::Hero.setItemData2Hero(hero, player)
		end
	end
	herolist.to_json
end

#取空闲的英雄列表
post '/hero/freelist' do
	player = request[:player]
	herolist = Model::Hero.getHeroList(player[:playerId])
	herolist.each do |hero|
		if hero.class == Hash
			Model::Hero.setItemData2Hero(hero, player)
		end
	end
	herolist.to_json
end

#英雄更换
post '/hero/replace' do
	player = request[:player]
	index = request[:req_parames][:index]
	freeHeroId = request[:req_parames][:freeHeroId]
	ret = Model::Hero.replaceHero(index, freeHeroId, player)
	ret.to_json
end

#英雄传承
post '/hero/trans' do
	player = request[:player]
	battleHeroId = request[:req_parames][:battleheroid]
	freeHeroId = request[:req_parames][:freeheroid]
	transtype = request[:req_parames][:transtype]
	ret = Model::Hero.transHero(battleHeroId, freeHeroId ,transtype, player)
	ret.to_json
end
#英雄级别大于1的
post '/hero/freelistlevelbigone' do
	levelbigoneHeroList = []
	player = request[:player]
	herolist = Model::Hero.getHeroList(player[:playerId])
	herolist.each do |hero|
		if hero[:level] > 1
			levelbigoneHeroList << hero
		end
	end
	levelbigoneHeroList.to_json
end

#英雄布阵
post '/hero/arrangebattle' do
	player = request[:player]
	battleHeroIdList = request[:req_parames][:battleheroidlist]
	ret = Model::Hero.arrangeAllBattleHero(battleHeroIdList ,player[:playerId])
	ret.to_json
end

#英雄进阶
post '/hero/advanced' do
	player = request[:player]
	battleHeroId = request[:req_parames][:battleheroid]
	freeHeroId = request[:req_parames][:freeheroid]
	ret = Model::Hero.advancedHero(battleHeroId, freeHeroId, player[:playerId])
	ret.to_json
end

#英雄培养预览
post '/hero/prebringup' do
	player = request[:player]
	heroId = request[:req_parames][:heroid]
	bringType = request[:req_parames][:bringtype]
	ret = Model::Hero.preBringupBattleHero(heroId, bringType, player[:playerId])
	ret.to_json
end

#英雄培养确认
post '/hero/bringup' do
	player = request[:player]
	heroId = request[:req_parames][:heroid]
	bringType = request[:req_parames][:bringtype]
	ret = Model::Hero.bringupBattleHero(heroId, bringType, player[:playerId])
	ret.to_json
end

#武将换装 
#参数 heroId：武将id , area：装备区域(1:装备类，2：兵法类), index:格子索引，itemId：装备id
#返回  retcode , 前端处理换装后的 阵容数据
post '/hero/equip/switch' do 
	player = request[:player]
	params = request[:req_parames]
	ret = Model::Hero.switchEquipment(player,params[:heroId],params[:area],param[:index],param[:itemId])
	ret.to_json
end

