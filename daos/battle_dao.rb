class BattleDao
	# 创建战役npc的列表
	# @param[Integer]
	# @return [Array]
	def createBatteNPC(battleId)

	end
	#取战役信息
	# @param[String,Integer]
	# @return [Array]
	def getSubBattleInfoHash(battleName, playerId)
		key = Const::Rediskeys.getBattleListKey(battleName, playerId)
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
  		battleMetaData = metaDao.
  	end
end