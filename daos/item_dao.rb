class ItemDao

	#====================================宝物
	#所有的宝物id列表
	def getPropIdList(playerId)
		#宝物id列表 key
		propIdListKey = Const::Rediskeys.getPropIdListKey(playerId)
		puts "propIdListKey 	--	#{propIdListKey}"
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
		propIdList = getPropIdList(playerId)
		if propIdList and propIdList.length > 0
			propKeyList = []
			propIdList.each do |propId|				
				propKeyList << Const::Rediskeys.getPropKey(playerId,propId)
			end
			jsonPropList = RedisClient.mget(propKeyList)
			jsonPropList.each do |prop|
				propList << JSON.parse(prop, {:symbolize_names => true})
			end
		end
		propList
	end

	#获取宝物信息
	#@param [Integer]
	#@return [Array] prop list
	def getPropData(playerId,iid)
		propKey = Const::Rediskeys.getPropKey(playerId,iid)
		propData = RedisClient.get(propKey)
		if propData
			JSON.parse(propData, {:symbolize_names => true}) 
		else
			nil
		end
	end

	#======================================已装备（武器防具坐骑兵法）
	#所有的已装备id列表
	def getEquipUsedIdList(playerId,sort)
		equipIdListKey = Const::Rediskeys.getEquipUsedIdListKey(playerId,sort)
		equipIdList = RedisClient.get(equipIdListKey)
		if equipIdList
			JSON.parse(equipIdList, {:symbolize_names => true})
		else
			[]
		end
	end
	#已装备列表
	def getEquipUsedList(playerId,sort)
		equipList = []
		equipIdList = getEquipUsedIdList(playerId,sort)
		if equipIdList and equipIdList.length > 0
			equipIdListKey = []
			equipIdList.each do |equipId|
				equipIdListKey << Const::Rediskeys.getEquipKey(playerId,equipId)
			end
			jsonEquipList = RedisClient.mget(equipIdListKey)
			jsonEquipList.each do |item|
				equipList << JSON.parse(item , {:symbolize_names => true})
			end
		end

		equipList 
	end

	#======================================未装备
	#所有的已装备id列表
	def getEquipUnusedIdList(playerId)
		equipIdListKey = Const::Rediskeys.getEquipUnusedIdListKey(playerId)
		equipIdList = RedisClient.get(equipIdListKey)
		if equipIdList
			JSON.parse(equipIdList, {:symbolize_names => true})
		else
			[]
		end
	end

	def getEquipUnusedList(playerId)
		equipList = []
		equipIdList = getEquipUnusedIdList(playerId)
		if equipIdList and equipIdList.length > 0
			equipListKey = []
			equipIdList.each do |equipId|
				equipIdListKey << Const::Rediskeys.getEquipKey(playerId,equipId)
			end
			jsonEquipList = RedisClient.mget(equipIdListKey)
			jsonEquipList.each do |equip|
				equipList << JSON.parse(equip , {:symbolize_names => true})
			end
		end

		equipList 
	end

	#获取宝物信息
	#@param [Integer]
	#@return [Array] prop list
	def getEquipData(playerId,id)
		equipKey = Const::Rediskeys.getEquipKey(playerId,id)
		RedisClient.get(equipKey)
	end


end