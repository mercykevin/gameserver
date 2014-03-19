module Model
	class Hero
		#招募英雄
		def self.recuritHero(templeteHeroId,player,recuritetype)
			metaDatao = MetaDao.instance
			commonDao = CommonDao.new
			heroDao = HeroDao.new
			templeteHero = metaDatao.getHeroMetaData(templeteHeroId)
			if ! templeteHero
				return {:retcode => Const::ErrorCode::HeroRecuritTempleteHeroIsNotExist}
			end
			#空闲的英雄列表
			heroIdList = heroDao.getHeroIdList(player[:playerId])
			#创建英雄
			hero = createHero(templeteHero, player, heroIdList)
			#更新相关信息到redis中
			heroIdListKey = Const::Rediskeys.getHeroListKey(player[:playerId])
			herokey = Const::Rediskeys.getHeroKey(hero[:heroId],player[:playerId])
			playerkey = Const::Rediskeys.getPlayerKey(player[:playerId])
			commonDao.update({herokey => hero, heroIdListKey => heroIdList, playerkey => player})
			{:retcode => Const::ErrorCode::Ok,:hero => hero}
		end
		#get a hero info 
		#@param [MetaData,Hash,Array] hero csv data,player info in Hash,
		#@return
		def self.createHero(templeteHero,player,heroIdList)
			heroDao = HeroDao.new
			#生成hero id
			heroId = heroDao.generateHeroId
			#创建hero
			hero = {}
			hero[:heroId] = heroId
			hero[:templeteHeroId] = templeteHero.GeneralID
			hero[:playerId] = player[:playerId]
			hero[:attack] = templeteHero.GInitialATK.to_f
			hero[:defend] = templeteHero.GInitialDEF.to_f
			hero[:intelegence] = 0
			hero[:blood] = templeteHero.GInitialHP.to_f 
			hero[:exp] = 0
			hero[:star] = templeteHero.GStart.to_i
			heroIdList << heroId
			hero
		end
		#register main hero
		#@param 
		def self.registerMainHero(templeteHeroId,player)
			metaDatao = MetaDao.instance
			commonDao = CommonDao.new
			heroDao = HeroDao.new
			templeteHero = metaDatao.getHeroMetaData(templeteHeroId)
			if ! templeteHero
				return {:retcode => Const::ErrorCode::HeroRecuritTempleteHeroIsNotExist}
			end
			playerId = player[:playerId]
			#上阵的英雄列表
			heroIdList = heroDao.getBattleHeroIdList(playerId)
			if heroIdList != nil && heroIdList.length > 0
				return {:retcode => Const::ErrorCode::HeroRegisterFailHeroExist}
			end
			#创建英雄
			hero = createHero(templeteHero, player, heroIdList)
			#更新相关信息到redis中
			heroIdListKey = Const::Rediskeys.getBattleHeroListKey(playerId)
			herokey = Const::Rediskeys.getHeroKey(hero[:heroId],playerId)
			commonDao.update({herokey => hero, heroIdListKey => heroIdList })
			{:retcode => Const::ErrorCode::Ok,:hero => hero}
		end
		#get a hero info 
		#@param [String,String] hero id ,player id
		#@return [Hash]
		def self.getHero(heroId,playerId)
			heroDao = HeroDao.new
			heroDao.get(heroid,playerId)
		end
		#get battle hero list 
		#@param [String] player id
		#@return [Array]
		def self.getBattleHeroList(playerId)
			heroDao = HeroDao.new
			heroDao.getBattleHeroList(playerId)
		end
	end # class
end # model definition
