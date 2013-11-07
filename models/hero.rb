module Model
	class Hero
		def self.recuritHero(templeteHeroId,playerId)
			player = ::Model::User.get(playerId)
			if ! player
				return {:retcode => ::Model::ErrorCode::PlayerIsNotExist}
			end
			heroId = RedisClient.incr(::Model::Rediskeys.getHeroIdAutoIncKey(playerId))
			templeteHero = getTempleteHero(templeteHeroId)
			if ! templeteHero
				return {:retcode => ::Model::ErrorCode::HeroRecuritTempleteHeroIsNotExist}
			end
			#创建hero
			hero = {}
			hero[:heroId] = heroId
			hero[:templeteHeroId] = templeteHeroId
			hero[:playerId] = playerId
			hero[:attack] = 0
			hero[:defend] = 0
			hero[:intelegence] = 0
			hero[:blood] = 0 
			hero[:exp] = 0 
			RedisClient.set(::Model::Rediskeys.getHeroKey(heroId,playerId),hero.to_json)
			#在player中增加一个英雄
			player["heroList"] << heroId
			::Model::User.set(player)
			{:retcode => ::Model::ErrorCode::Ok,:hero => hero}
		end

		def self.getHeroList(playerId)
			player = ::Model::User.get(playerId)
			heroIdList = player["heroList"]
		end

		def self.getRecuritHeroList(playerId)
		end

		def self.getHero(heroId,playerId)
			heroData = RedisClient.get(::Model::Rediskeys.getHeroKey(heroId,playerId))
			if heroData and not heroData.empty?
				JSON.parse(heroData)
			end
		end

		def self.getTempleteHero(templeteHeroId)
			
		end

		
	end # class
end # model definition
