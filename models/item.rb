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


		#
		# 获得道具，武器防具坐骑兵法宝物
		#
		def self.addItem(playerId,iid,count)
			
			metaDao = MetaDao.instance
			tempItem = metaDao.getTempItem(iid)
			commonDao = CommonDao.new
			
			#不存在的 iid
			if ! tempItem
				GameLogger.debug("Model::Item.addItem method params iid:#{iid} => tempItem is not exists !")
				return {:retcode => Const::ErrorCode::IllegeParam}
			end
			#数量非法
			if ! ( count && count.is_a?(Integer) && count > 0 )
				GameLogger.debug("Model::Item.addItem method params count:#{count} => count is illege !")
				return {:retcode => Const::ErrorCode::IllegeParam}
			end

			retHash = addItemNoSave(playerId,iid,count,tempItem)

			commonDao.update(retHash)

		end


		#
		# 添加道具，未保存
		# @param 
		# 
		def self.addItemNoSave(playerId , iid , count , tempItem)
			itemDao = ItemDao.new
			GameLogger.info("Model::Item.addItemNoSave method params playerId:#{playerId} ,iid:#{iid} ,count:#{count} ,itemType:#{tempItem.eType} .")
			#宝物类
			if tempItem.eType == Const::ItemTypeProp
				propData = itemDao.getPropData(playerId,tempItem.propID)
				
				#有该宝物，数量累加
				if propData
					#修改宝物数量
					propData[:count] = propData[:count].to_i + count
					propData[:updatedAt] = Time.now.to_i
				else
					#添加宝物
					propData = {}
					propData[:iid] = tempItem.propID
					propData[:count] = count
					#宝物类型
					propData[:type] = tempItem.pType.to_i
					propData[:createdAt] = Time.now.to_i
					propData[:updatedAt] = Time.now.to_i
				end
				#添加到宝物列表
				propIdList = itemDao.getPropIdList(playerId)
				if ! propIdList.include?(iid)
					propIdList << iid
				end
				#key
				propKey = Const::Rediskeys.getPropKey(playerId,tempItem.propID)
				propIdListKey = Const::Rediskeys.getPropIdListKey(playerId)

				return { propIdListKey => propIdList , propKey => propData }

			elsif
				#所有添加的道具
				equipHash = {}
				#添加到未装备列表 ，类型
				equipIdList = itemDao.getEquipUnusedIdList(playerId , tempItem.eType)
				for i in 1..count do
					#兵法
					if tempItem.eType == Const::ItemTypeBook
						equip = {}
						equip[:id] = RedisClient.incr(Const::Rediskeys.getEquipIdAutoIncKey())
						equip[:iid] = tempItem.bookID
						equip[:star] = tempItem.bStar
						equip[:level] = tempItem.bLevel
						equip[:createdAt] = Time.now.to_f
						equip[:updatedAt] = Time.now.to_f
					#装备类	
					else
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
					end

					#道具的 key
					equipKey = Const::Rediskeys.getEquipKey(playerId,equip[:id])
					equipHash[equipKey] = equip 
					#装备列表
					equipIdList << equip[:id]
				end
				
				#未装备列表key
				equipIdListKey = Const::Rediskeys.getEquipUnusedIdListKey(playerId , tempItem.eType)
				equipHash[equipIdListKey] = equipIdList
				equipHash

			end
			
		end

		#未装备列表
		def self.getEquipUnusedList(playerId,sort)
			itemDao = ItemDao.new
			itemDao.getEquipUnusedList(playerId,sort)
		end

		#已装备列表
		def self.getEquipUsedList(playerId)
			itemDao = ItemDao.new
			itemDao.getEquipUsedList(playerId)
		end



		# 获取装备
		def self.getProp(playerId,iid)
			propKey = Const::Rediskeys.getPropKey(playerId,iid)
			propData = RedisClient.get(propKey)
			if propData and not propData.empty?
				JSON.parse(propData, {:symbolize_names => true}) 
			end
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