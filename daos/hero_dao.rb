class HeroDao
	#get all hero id list by playerId
	#@param [Integer] player id
	#@return [Array] id list
	def getHeroIdList(playerId)
		heroIdListKey = Const::Rediskeys.getHeroListKey(playerId)
		heroIdList = RedisClient.get(heroIdListKey)
		if heroIdList
			JSON.parse(heroIdList, {:symbolize_names => true})
		else
			[]
		end
	end
	#取空闲英雄的列表
	#@param [Integer]
	#@return [Array] free hero list
	def getHeroList(playerId)
		heroList = []
		heroIdList = getHeroIdList(playerId)
		if heroIdList and heroIdList.length > 0
			herokeyList = []
			heroIdList.each do |heroId|
				herokeyList << Const::Rediskeys.getHeroKey(heroId,playerId)
			end
			jsonHeroList = RedisClient.mget(herokeyList)
			jsonHeroList.each do |hero|
				heroList << JSON.parse(hero, {:symbolize_names => true})
			end
		end
		heroList
	end
	#get hero info by hero id and player id
	#@param [Integer,Integer] hero id and player id
	#@return [Hash] hero info
	def get(heroId,playerId)
		herokey = Const::Rediskeys.getHeroKey(heroId,playerId)
		hero = RedisClient.get(herokey)
		if hero
			JSON.parse(hero, {:symbolize_names => true}) 
		else
			nil
		end
	end
	#验证英雄是否存在
	#@param [Integer,Integer]
	#@return [Boolean]
	def exist?(heroId,playerId)
		herokey = Const::Rediskeys.getHeroKey(heroId,playerId)
		RedisClient.exists(herokey)
	end
	#get hero info by hero id and player id
	#@param [Integer] player id
	#@return [Array] hero list
	def getBattleHeroList(playerId)
		heroList = []
		heroIdList = getBattleHeroIdList(playerId)
		if heroIdList and heroIdList.length > 0
			herokeyList = []
			heroIdList.each do |heroId|
				herokeyList << Const::Rediskeys.getHeroKey(heroId,playerId)
			end
			jsonHeroList = RedisClient.mget(herokeyList)
			jsonHeroList.each do |hero|
				heroList << JSON.parse(hero, {:symbolize_names => true})
			end
		end
		heroList
	end
	#get hero list in battle 
	#@param [Integer] player id
	#@return [Array] hero list
	def getBattleHeroIdList(playerId)
		heroIdListKey = Const::Rediskeys.getBattleHeroListKey(playerId)
		heroIdList = RedisClient.get(heroIdListKey)
		if heroIdList
			JSON.parse(heroIdList, {:symbolize_names => true})
		else
			[]
		end
	end

	# generate player id with redis inc.
	# 
  	# @return [String] player id
	def generateHeroId
		RedisClient.incr(Const::Rediskeys.getHeroIdAutoIncKey)
	end
	# 英雄招募的相关信息.
	# 
  	# @return [Hash] recruiteinfo
	def getHeroRecruiteInfo(playerId)
		key = Const::Rediskeys.getHeroRecruiteKey(playerId)
		info = RedisClient.get(key)
		if info
			JSON.parse(info, {:symbolize_names => true})
		else
			{}
		end
	end
end