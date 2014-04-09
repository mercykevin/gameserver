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
		heroMap = {}
		heroIdList = getBattleHeroIdList(playerId)
		if heroIdList and heroIdList.length > 0
			herokeyList = []
			heroIdList.each do |heroId|
				if heroId != Const::HeroEmpty && heroId != Const::HeroLocked
					herokeyList << Const::Rediskeys.getHeroKey(heroId,playerId)
				end
			end
			jsonHeroList = RedisClient.mget(herokeyList)
			jsonHeroList.each do |heroJson|
				hero = JSON.parse(heroJson, {:symbolize_names => true})
				heroMap[hero[:heroId]] = hero
			end
		end
		heroIdList.each_with_index do |heroId,index|
			if heroId == Const::HeroEmpty || heroId == Const::HeroLocked
				heroList[index] = heroId
			else
				heroList[index] = heroMap[heroId]
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
	#获取已经解锁的数量 
	#@param [Integer] player id
	#@return [Integer] battle count 战斗位
	def getBattleCount(playerId)
		count = 0
		heroIdList = getBattleHeroIdList(playerId)
		heroIdList.each do |heroId|
			if heroId != Const::HeroLocked
				count = count + 1
			end
		end
		count
	end
	# generate player id with redis inc.
	# 
  	# @return [String] player id
	def generateHeroId
		RedisClient.incr(Const::Rediskeys.getHeroIdAutoIncKey)
	end
	# 英雄招募的相关信息.
	# @param [Integer] 角色id
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
	#处理英雄升级
	#@param[Integer,Integer]
	#@return
	def handleHeroLevelUp(hero,addexp)
		metaDao = MetaDao.instance
		hero[:exp] = hero[:exp] + addexp
		maxHeroLevel = metaDao.getMaxHeroLevel()
		if hero[:level] < maxHeroLevel
			#取所有英雄的配置表
			heroLevelMetaList = metaDao.getAllHeroLevelMetaData
			if hero[:exp] >= heroLevelMetaList[heroLevelMetaList.length-1].lUPGeneral.to_i
				hero[:exp] = heroLevelMetaList[heroLevelMetaList.length-1].levelGeneral.to_i
			else
				for i in hero[:level]..maxHeroLevel - 1 do
					if hero[:exp] >= heroLevelMetaList[i-1].lUPGeneral.to_i and hero[:exp] < heroLevelMetaList[i].lUPGeneral.to_i
						hero[:level] = heroLevelMetaList[i-1].levelGeneral.to_i
						break
					end
				end
			end
		end
	end
	#处理英雄情义
	#@param[Array,Integer] 英雄列表
	#@return[Hash] 返回情义
	def handleHeroFriendShip(heroList,playerId)
	end

end