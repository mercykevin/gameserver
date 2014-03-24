class CommonDao
	#更新redis，带watch和事务功能
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
				if multiret == nil || multiret.empty? || multiret[0] != 'OK'
					#抛出乐观锁异常
					raise RedisStaleObjectStateException
				end
			end
		end
	end
end