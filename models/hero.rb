module Model
	class Hero
		#招募英雄
		def self.recuritHero(templeteHeroId,playerId,recuritetype)
			metaDatao = MetaDao.instance
			player = Model::Player.get(playerId)
			heroId = RedisClient.incr(Const::Rediskeys.getHeroIdAutoIncKey)
			templeteHero = metaDatao.getHeroMetaData(templeteHeroId)
			if ! templeteHero
				return {:retcode => Const::ErrorCode::HeroRecuritTempleteHeroIsNotExist}
			end
			#创建hero
			hero = {}
			hero[:heroId] = heroId
			hero[:templeteHeroId] = templeteHeroId
			hero[:playerId] = playerId
			hero[:attack] = templeteHero。
			hero[:defend] = 0
			hero[:intelegence] = 0
			hero[:blood] = 0 
			hero[:exp] = 0 
			RedisClient.set(::Const::Rediskeys.getHeroKey(heroId,playerId),hero.to_json)
			#在player中增加一个英雄
			player["heroList"] << heroId
			Model::Player.set(player)
			{:retcode => ::Const::ErrorCode::Ok,:hero => hero}
		end

		def self.getHeroList(playerId)
			player = ::Model::Player.get(playerId)
			heroIdList = player["heroList"]
		end

		def self.getRecuritHeroList(playerId)
		end

		def self.getHero(heroId,playerId)
			heroData = RedisClient.get(::Const::Rediskeys.getHeroKey(heroId,playerId))
			if heroData and not heroData.empty?
				JSON.parse(heroData)
			end
		end

		def self.getTempleteHero(templeteHeroId)
			
		end

		
	end # class
end # model definition
