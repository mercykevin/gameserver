class SessionDao
	#根据session获取玩家id
	#@param [String] sessionid
	#@return [Intger]
	def getPlayerIdBySession(sessionId)
		SessionRedisClient.get(Const::Rediskeys.getSessionKey(sessionId))
	end
	#设置session 与玩家id对应
	#@param [String]
	def setPlayerIdBySession(sessionId,playerId)
		SessionRedisClient.set(Const::Rediskeys.getSessionKey(sessionId),playerId)
	end
end