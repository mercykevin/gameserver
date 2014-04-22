class CommonDao
	#更新redis，带watch和事务功能
	#@param [Hash]
	#@return [Array]
	def update(entities)
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

	#更新redis，带watch和事务功能
	#@param [Hash] { string:{k1:val,k2:val} , zset:{ k1:{value,score} ,k2:{value,score} } }
	#@return [Array]
	def updateWithSort(entities)
		if entities and not entities.empty?
			# use block for thread safe
			RedisClient.watch(entities.keys) do
				multiret = RedisClient.multi do |multi|
					entities.each do |sort,kvs|
						kvs.each do |k,v|
							if v == nil
								multi.del(k)
							else
								case sort
								when "string"
									multi.set(k,v.to_json)
								when "zset" 
									v.each do |value,score|
										multi.zadd(k,score,value)
									end
								when "list"
								when "hash"
								when "none"
								end
							end
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