module Model
	class Item
		# 获取装备
		def self.getEquip(playerId,equipId)
			equipKey = Const::Rediskeys.getEquipKey(playerId,equipId)
			equipData = RedisClient.get(equipKey)
			if equipData and not equipData.empty?
				JSON.parse(equipData, {:symbolize_names => true}) 
			end
		end


		# 添加装备
		def self.addEquip(playerId,iid,count)
			
			metaDao = MetaDao.instance
			tempItem = metaDao.getTempItem(iid)

			#不存在的 iid
			if ! tempItem
				GameLogger.debug("Model::Item.addEquip method params iid:#{iid} => tempItem is not exists !")
				return {:retcode => Const::ErrorCode::IllegeParam}
			end

			#TODO 其他条件验证
			equip = initEquip(playerId,tempItem,count)
			
			#道具的 key
			equipKey = Const::Rediskeys.getEquipKey(playerId,equip[:id])
			commonDao = CommonDao.new
			commonDao.update(equipKey => equip)

		end


		#初始化装备信息
		def self.initEquip(playerId,tempItem,count)
			equip = {}
			equip[:id] = RedisClient.incr(Const::Rediskeys.getEquipIdAutoIncKey())
			equip[:iid] = tempItem.equipmentID
			equip[:star] = tempItem.eStar
			equip[:level] = tempItem.elevel
			equip[:type] = tempItem.eType.to_i
			equip[:attack] = tempItem.eATK.to_f
			equip[:defence] = tempItem.eDEF.to_f
			equip[:brain] = tempItem.eINT.to_f
			equip[:blood] = tempItem.eHP.to_f
			equip[:createdAt] = Time.now.to_f
			equip[:updatedAt] = Time.now.to_f
			# 其他属性量表读取，加成量表读取计算
			# equip[:attackUp] = tempitem.eATKUP
			# equip[:defenceUp] = tempitem.eDEFUP
			# equip[:brainUp] = tempitem.eINTUP
			# equip[:bloodUp] = tempitem.eHPUP
			# equip[:defenceUp] = tempitem.eDEFUP
			equip
		end

		#未装备列表
		def self.getEquipUnusedList(playerId)
			itemDao = ItemDao.new
			itemDao.getEquipUnusedList(playerId)
		end

		#已装备列表
		def self.getEquipUsedList(playerId,sort)
			itemDao = ItemDao.new
			itemDao.getEquipUsedList(playerId,sort)
		end



		# 获取装备
		def self.getProp(playerId,iid)
			propKey = Const::Rediskeys.getPropKey(playerId,iid)
			propData = RedisClient.get(propKey)
			if propData and not propData.empty?
				JSON.parse(propData, {:symbolize_names => true}) 
			end
		end

		# 添加宝物
		def self.addProp(playerId,iid,count)
			metaDao = MetaDao.instance
			itemDao = ItemDao.new
			#不存在的 iid
			tempItem = metaDao.getTempItem(iid)
			if ! tempItem
				GameLogger.debug("Model::Item.addProp method params iid:#{iid} => tempItem is not exists !")
				return {:retcode => Const::ErrorCode::IllegeParam}
			end
			#数量非法 TODO
			if ! ( count && count.is_a?(Integer) )
				GameLogger.debug("Model::Item.addProp method params count:#{count} => count is illege !")
				return {:retcode => Const::ErrorCode::IllegeParam}
			end

			propData = itemDao.getPropData(playerId,iid)
			propKey = Const::Rediskeys.getPropKey(playerId,iid)
			commonDao = CommonDao.new
			#有该宝物，数量累加
			if propData
				#修改宝物数量
				propData[:count] = propData[:count].to_i + count
				propData[:updatedAt] = Time.now.to_i
				commonDao.update(propKey => propData)
			else
				#添加宝物
				propData = {}
				propData[:iid] = iid
				propData[:count] = count
				propData[:type] = tempItem.pType.to_i
				propData[:createdAt] = Time.now.to_i
				propData[:updatedAt] = Time.now.to_i
				commonDao.update(propKey => propData)
			end

			#添加到宝物列表
			propIdList = itemDao.getPropIdList(playerId)
			if ! propIdList.include?(iid)
				propIdList << iid
			end

			propIdListKey = Const::Rediskeys.getPropIdListKey(playerId)
			commonDao.update(propIdListKey => propIdList)
		end


		#使用宝物
		def self.useProp(playerId,iid,count)
		end

		#消耗装备
		def self.costEquip(playerId,iid,count)
		end


		
		#宝物
		def self.getPropList(playerId)
			itemDao = ItemDao.new
			itemDao.getPropList(playerId)
		end


	end

end