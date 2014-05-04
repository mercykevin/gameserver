class ItemDao

	#====================================宝物
	#取所有宝物列表
	#根据key模糊匹配所有的宝物
	#@param [Integer] playerId
	#@return [Array] 宝物列表
	def getPropList(playerId)
		commKey = Const::Rediskeys.getPropIdListKey(playerId)
		propKeyList = RedisClient.keys(commKey)
		propObjList = []
		if not propKeyList.empty?
			propList = RedisClient.mget(propKeyList)
			if propList
				propList.each do |prop|
					propObjList << JSON.parse(prop, {:symbolize_names => true}) 
				end
			end
		end
		propObjList
	end

	#获取宝物信息
	#@param [Integer , Integer] playerId，iid
	#@return [Array] 宝物信息
	def getPropData(playerId,iid)
		propKey = Const::Rediskeys.getItemKey(playerId,Const::ItemTypeProp,iid)
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
				equipIdListKey << Const::Rediskeys.getItemKey(playerId,sort,equipId)
			end
			jsonEquipList = RedisClient.mget(equipIdListKey)
			jsonEquipList.each do |equip|
				equipList << JSON.parse(equip , {:symbolize_names => true})
			end
		end
		equipList 
	end

	#获取武器防具坐骑
	#@param [Integer,Integer] playerId ,id (装备id) 
	#@return [Hash] 得到装备信息
	def getEquipmentData(playerId,id)
		#武器
		equipKey = Const::Rediskeys.getItemKey(playerId,Const::ItemTypeWeapon,id)
		equipData = RedisClient.get(equipKey)
		if equipData
			return JSON.parse(equipData, {:symbolize_names => true}) 
		end
		#防具
		equipKey = Const::Rediskeys.getItemKey(playerId,Const::ItemTypeShield,id)
		equipData = RedisClient.get(equipKey)
		if equipData
			return JSON.parse(equipData, {:symbolize_names => true}) 
		end
		#坐骑
		equipKey = Const::Rediskeys.getItemKey(playerId,Const::ItemTypeHorse,id)
		equipData = RedisClient.get(equipKey)
		if equipData
			return JSON.parse(equipData, {:symbolize_names => true}) 
		end
		#兵法
		equipKey = Const::Rediskeys.getItemKey(playerId,Const::ItemTypeBook,id)
		equipData = RedisClient.get(equipKey)
		if equipData
			return JSON.parse(equipData, {:symbolize_names => true}) 
		end
		return nil
	end

	#验证装备id是否存在
	#@param [Integer,Integer]
	#@return [Boolean]
	def exist?(playerId ,sort, id)
		equipKey = Const::Rediskeys.getItemKey(playerId,Const::ItemTypeWeapon,id)
		if not equipKey
			#防具
			equipKey = Const::Rediskeys.getItemKey(playerId,Const::ItemTypeShield,id)
		else
			#坐骑
			equipKey = Const::Rediskeys.getItemKey(playerId,Const::ItemTypeHorse,id)
		end
		RedisClient.exists(equipKey)
	end

	#获取兵法信息
	#@param [Integer,Integer] playerId 兵法id
	#@return [Hash]
	def getBookData(playerId,id)
		bookKey = Const::Rediskeys.getItemKey(playerId,Const::ItemTypeBook,id)
		bookData = RedisClient.get(bookKey)
		if bookData 
			JSON.parse(bookData, {:symbolize_names => true}) 
		else
			nil
		end
	end
	#所有的装备（武器防具坐骑）
	#包括上阵和为上阵的
	#@param [Integer] playerId
	def getEquipeAllList(playerId)
		weaponKeys = Const::Rediskeys.getEquipKeyAllList(playerId , Const::ItemTypeWeapon)
		shieldKeys = Const::Rediskeys.getEquipKeyAllList(playerId , Const::ItemTypeShield)
		horseKeys = Const::Rediskeys.getEquipKeyAllList(playerId , Const::ItemTypeHorse)
		wlist = RedisClient.keys(weaponKeys)
		slist = RedisClient.keys(shieldKeys)
		hlist = RedisClient.keys(horseKeys)
		equipKeyList = wlist | slist | hlist
		GameLogger.info("Model::Item.getEquipeAllList playerId:'#{playerId}' equipKeyList size '#{equipKeyList.size}' , weapons size '#{wlist.size}' ,shields size '#{slist.size}' ,horses size '#{hlist.size}'!")
		equipObjList = []
		if not equipKeyList.empty?
			equipList = RedisClient.mget(equipKeyList)
			if equipList
				equipList.each do |equip|
					equipObjList << JSON.parse(equip, {:symbolize_names => true}) 
				end
			end
		end
		equipObjList
	end

	#所有的兵法
	#包括上阵和未上阵的
	def getBookAllList(playerId)
		commKey = Const::Rediskeys.getBookKeyAllList(playerId)
		bookKeyList = RedisClient.keys(commKey)
		bookObjList = []
		if not bookKeyList.empty?
			bookList = RedisClient.mget(bookKeyList)
			if bookList
				bookList.each do |book|
					bookObjList << JSON.parse(book, {:symbolize_names => true}) 
				end
			end
		end
		bookObjList
	end

	#兵法碎片
	#@param [Integer,Integer] playerId 兵法iid
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