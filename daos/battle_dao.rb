class BattleDao
	# 创建战役npc的列表
	# @param[Integer]
	# @return [Array]
	def createBatteNPC(battleId)

	end
	#取战役信息
	# @param[Integer,Integer]
	# @return [Hash]
	def getSubBattleInfoMap(battleId, playerId)
		key = Const::Rediskeys.getBattleListKey(battleId, playerId)
		battleInfo = RedisClient.get(key)
		if battleInfo
			JSON.parse(battleInfo, {:symbolize_names => true})
		else
			{}
		end
	end
  	# 添加战役信息到列表中
  	# @param [Integer]
  	# @return [Hash]
  	def updateSubBattle(battleId,stars,isWin)
  		metaDao = MetaDao.instance
  	end
  	# 取大战役的
  	# @param [Integer]
  	# @return [Array]		
  	def getBattleIdList(playerId)
  		key = Const::Rediskeys.getBattleIdListKey(playerId)
  		battleIdList = RedisClient.get(key)
  		if battleIdList
  			JSON.parse(battleIdList, {:symbolize_names => true})
  		else
  			[]
  		end
  	end
  	# 添加战役信息
  	# @param [Integer]
  	# @return [Hash]
  	def addBattleIdToList(subBattleId,playerId)
  		battleIdList = getBattleIdList(playerId)
		if not battleIdList.include?(subBattleId)
			battleIdList << subBattleId
		end
		key = Const::Rediskeys.getBattleIdListKey(playerId)
		{key=>battleIdList}
  	end
end