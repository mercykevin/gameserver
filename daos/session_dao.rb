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
	#设置临时数据到session Redis中
	def setAttributes(entities)
		if entities and not entities.empty?
			# use block for thread safe
			RedisClient.watch(entities.keys) do
				multiret = RedisClient.multi do |multi|
					entities.each do |k,v|
						if v == nil
							multi.del(k)
						else
							multi.set(k,v.to_json)
						end
					end
				end
				if multiret == nil || multiret.empty?
					#抛出乐观锁异常
					raise RedisStaleObjectStateException
				end
			end
		end
	end
end