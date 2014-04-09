class ItemDao

	#====================================宝物

	#获取所有宝物iid列表
	#@param [Integer] playerId
	#@return [Array] 宝物的iid列表
	def getPropIdList(playerId)
		#宝物id列表 key
		propIdListKey = Const::Rediskeys.getPropIdListKey(playerId)
		propIdList = RedisClient.get(propIdListKey)
		if propIdList
			JSON.parse(propIdList, {:symbolize_names => true})
		else
			[]
		end
	end

	#取所有宝物列表
	#@param [Integer] playerId
	#@return [Array] 宝物列表
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
	#@param [Integer , Integer] playerId，iid
	#@return [Array] 宝物信息
	def getPropData(playerId,iid)
		propKey = Const::Rediskeys.getPropKey(playerId,iid)
		propData = RedisClient.get(propKey)
		if propData
			JSON.parse(propData, {:symbolize_names => true}) 
		else
			nil
		end
	end


	#======================================未上阵装备

	#根据类型得到未上阵id列表
	#param [Iteger,Integer] playerId,sort(武器:1,防具:2,坐骑:3,兵法:4)
	#@return [Array] 装备id列表
	def getEquipUnusedIdList(playerId,sort)
		equipIdListKey = Const::Rediskeys.getEquipUnusedIdListKey(playerId,sort)
		equipIdList = RedisClient.get(equipIdListKey)
		if equipIdList
			JSON.parse(equipIdList, {:symbolize_names => true})
		else
			[]
		end
	end

	#根据类型得到未上阵的装备列表
	#@param [Integer,Integer] playerId ,sort 
	#@return [Array] 未上阵列表
	def getEquipUnusedList(playerId,sort)
		equipList = []
		equipIdList = getEquipUnusedIdList(playerId,sort)
		if equipIdList and equipIdList.length > 0
			equipIdListKey = []
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

	#获取装备信息，包括武器防具坐骑兵法
	#@param [Integer,Integer] playerId ,id (装备id) 
	#@return [Hash] 得到装备信息
	def getEquipAllData(playerId,id)
		equipKey = Const::Rediskeys.getEquipKey(playerId,id)
		equipData = RedisClient.get(equipKey)
		if equipData and not equipData.empty?
			JSON.parse(equipData, {:symbolize_names => true}) 
		else
			nil
		end
	end

	#验证装备id是否存在
	#@param [Integer,Integer]
	#@return [Boolean]
	def exist?(playerId , heroId)
		equipKey = Const::Rediskeys.getEquipKey(playerId , heroId)
		RedisClient.exists(equipKey)
	end

	#获取武器防具坐骑
	def getEquipmentData(playerId,id)
		equipData = getEquipAllData(playerId,id)
		type = equipData[:type] 
		if equipData and ( type == Const::ItemTypeWeapon or type == Const::ItemTypeShield or type == Const::ItemTypeHorse)
			return equipData
		else
			nil
		end
	end

	#获取兵法信息
	def getBookData(playerId,id)
		bookData = getEquipAllData(playerId,id)
		if bookData and bookData[:type] == Const::ItemTypeBook
			return bookData
		else
			nil
		end
	end

	#所有的兵法
	def getBookList(playerId)
		equipKey = Const::Rediskeys.getEquipKey(playerId , heroId)
	end

	#兵法碎片
	def getBookFragmentData(playerId, bookIid)
		bookFragmentKey = Const::Rediskeys.getBookFragmentKey(playerId,bookIid)
		formateDataByKey(bookFragmentKey)
	end
	
	def formateDataByKey(key)
		data = RedisClient.get(key)
		if data and not data.empty?
			JSON.parse(data, {:symbolize_names => true}) 
		else
			nil
		end
	end



end