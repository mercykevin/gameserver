class ItemDao

	#所有的宝物id列表
	def getPropListKey(playerId)
		#宝物id列表 key
		propIdListKey = Const::Rediskeys.getPropListKey(playerId)
		propIdList = RedisClient.get(propIdListKey)
		if propIdList
			JSON.parse(propIdList, {:symbolize_names => true})
		else
			[]
		end
	end
	#取宝物列表
	#@param [Integer]
	#@return [Array] prop list
	def getPropList(playerId)
		propList = []
		propIdList = getPropListKey(playerId)
		if propIdList and propIdList.length > 0
			propKeyList = []
			propIdList.each do |propId|				
				propKeyList << Const::Rediskeys.getItemKey(propId,playerId)
			end
			jsonPropList = RedisClient.mget(propKeyList)
			jsonPropList.each do |prop|
				propList << JSON.parse(prop, {:symbolize_names => true})
			end
		end
		propList
	end

	#======================================
	#所有的已装备id列表
	def getItemUsedIdListKey(playerId)
		#宝物id列表 key
		propIdListKey = Const::Rediskeys.getItemUsedIdListKey(playerId)
		propIdList = RedisClient.get(propIdListKey)
		if propIdList
			JSON.parse(propIdList, {:symbolize_names => true})
		else
			[]
		end
	end
	#已装备列表
	def getItemUsedList(playerId,sort)
		itemList = []
		itemIdList = getItemUsedIdListKey(playerId,sort)
		if itemIdList and itemIdList.length > 0
			itemIdListKey = []
			itemIdList.each do |itemId|
				itemIdListKey << Const::Rediskeys.getItemUsedIdListKey(playerId)
			end
			jsonItemList = RedisClient.mget(itemIdListKey)
			jsonItemList.each do |item|
				itemList << JSON.parse(item , {:symbolize_names => true})
			end
		end

		itemList 
	end

	#======================================
	#未装备列表

	#所有的已装备id列表
	def getItemUnusedIdListKey(playerId)
		#宝物id列表 key
		propIdListKey = Const::Rediskeys.getItemUnusedIdListKey(playerId)
		propIdList = RedisClient.get(propIdListKey)
		if propIdList
			JSON.parse(propIdList, {:symbolize_names => true})
		else
			[]
		end
	end

	def getItemUnusedList(playerId)
		itemList = []
		itemIdList = getItemUnusedIdListKey(playerId)
		if itemIdList and itemIdList.length > 0
			itemIdListKey = []
			itemIdList.each do |itemId|
				itemIdListKey << Const::Rediskeys.getItemUnusedIdListKey(playerId)
			end
			jsonItemList = RedisClient.mget(itemIdListKey)
			jsonItemList.each do |item|
				itemList << JSON.parse(item , {:symbolize_names => true})
			end
		end

		itemList 
	end



end