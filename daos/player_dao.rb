require "json"

class PlayerDao
	# get player info.
  	#
  	# @param [String] playerId 
  	# @return [Hash] player's information store with Hash or nil if player is not exist
	def getPlayer(playerId)
		playerIdKey = Const::Rediskeys.getPlayerKey(playerId)
		player = RedisClient.get(playerIdKey)
		if player
			JSON.parse(player, {:symbolize_names => true})
		else
			nil
		end
	end

	# get player info.
	#
  	# @param [String] player name 
  	# @return [Hash] player's information store with Hash or nil if player is not exist
	def getPlayerByName(playerName)
		playerNameKey = Const::Rediskeys.getPlayerNameKey(playerName)
		if RedisClient.exists(playerNameKey)
			playerId = RedisClient.get(playerNameKey)
			getPlayer(playerId)
		else
			nil
		end
	end
	# generate player id with redis inc.
	# 
  	# @return [String] player id
	def generatePlayerId
		RedisClient.incr(Const::Rediskeys.getPlayerIdAutoIncKey)
	end
	# is exist player with player name
	#
	# @return [false or true] 
	def existByName?(playerName)
		playerNameKey = Const::Rediskeys.getPlayerNameKey(playerNameKey)
		RedisClient.exists(playerNameKey)
	end
	# create player into redis
	# 
	def create(player)
		playerIdKey = Const::Rediskeys.getPlayerKey(player[:playerId])
		playerNameKey = Const::Rediskeys.getPlayerNameKey(player[:playerName])
		RedisClient.watch(playerIdKey, playerNameKey) do
			multiret = RedisClient.multi do |multi|
				multi.set(playerIdKey,player.to_json)
				multi.set(playerNameKey,player[:playerId])
			end
			if multiret == nil || multiret.empty? || multiret[0] != 'OK'
			#抛出乐观锁异常
				raise RedisStaleObjectStateException
			end
		end
		#将player添加到所有用户列表中
		RedisClient.zadd(Const::Rediskeys.getAllPlayerIdListKey, Time.now().to_i, player[:playerId])
	end

	#处理用户升级
	#@param[Integer,Integer]
	#@return
	def handlePlayerLevelUp(player,addexp)
		metaDao = MetaDao.instance
		player[:exp] = player[:exp] + addexp
		maxLevel = metaDao.getMaxPlayerLevel()
		if player[:level] < maxLevel
			#取所有英雄的配置表
			levelMetaList = metaDao.getAllPlayerLevelMetaData()
			if player[:exp] >= levelMetaList[-1].cEXP.to_i
				player[:exp] = levelMetaList[-1].cEXP.to_i
			else
				for i in player[:level]..maxLevel - 1 do
					if player[:exp] >= levelMetaList[i-1].cEXP.to_i and player[:exp] < levelMetaList[i].cEXP.to_i
						player[:level] = levelMetaList[i-1].characterLevel.to_i
						break
					end
				end
			end
		end
	end

end