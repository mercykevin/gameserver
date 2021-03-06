class TaskDao

	#获取玩家可以显示的任务列表 iid:status
	#@param [Integer] playerId
	#@return [Hash] "iid":status 
	def getDisplayList(playerId)
		taskDisplayedsKey = Const::Rediskeys::getTaskDisplayedsKey(playerId)
		list = RedisClient.get(taskDisplayedsKey)
		if list
			JSON.parse(list)
		else
			nil
		end
	end

	#获取玩家已经完成的任务列表 iid列表
	#@param [Integer] playerId
	#@return [Array] Integer 数组 
	def getComplatedList(playerId)
		taskComplatedsKey = Const::Rediskeys::getTaskComplatedsKey(playerId)
		list = RedisClient.get(taskComplatedsKey)
		if list
			JSON.parse(list)
		else
			nil
		end
	end

	#获取玩家已经领取奖励的任务iid列表 
	#@param [Integer] playerId
	#@return [Array] Integer 数组
	def getAwardedList(playerId)
		taskDisplayedsKey = Const::Rediskeys::getTaskAwardedKey(playerId)
		list = RedisClient.get(taskDisplayedsKey)
		if list
			JSON.parse(list)
		else
			nil
		end
	end


end
