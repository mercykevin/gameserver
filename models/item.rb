module Model
	#
	# TODO 装备完道具要 更新 未装备列表 
	#
	class Item

		#获得道具，武器防具坐骑兵法宝物
		#@param [Integer,Integer,Integer] playerId,iid,count 
		#@return [Hash]
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

			retHash = addItemNoSave(playerId,iid,count)

			commonDao.update(retHash)

			{:retcode => Const::ErrorCode::Ok }
		end


		#添加道具（武器防具坐骑兵法宝物），没有保存
		#@param [Integer,Integer,Integer] playerId,iid,count 
		#@return [Hash]
		def self.addItemNoSave(playerId , iid , count)
			itemDao = ItemDao.new
			metaDao = MetaDao.instance
			tempItem = metaDao.getTempItem(iid)
			GameLogger.info("Model::Item.addItemNoSave method params playerId:#{playerId} , count:#{count} ,itemType:#{tempItem.eType} .")
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
				if ! propIdList.include?(tempItem.propID)
					propIdList << tempItem.propID
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

		#根据类型获取未上阵的装备列表
		#@param [Integer,Integer] playerId,sort (武器防具坐骑兵法宝物 = 1,2,3,4,5) 
		#@return [Array]
		def self.getEquipUnusedList(playerId,sort)
			itemDao = ItemDao.new
			itemDao.getEquipUnusedList(playerId,sort)
		end

		#获取所有宝物列表
		#@param [Integer] playerId
		#@return [Array]
		def self.getPropList(playerId)
			itemDao = ItemDao.new
			itemDao.getPropList(playerId)
		end

		#获取装备详细
		#@param [Integer] playerId,id
		#@return [Hash]
		def self.getEquipData(playerId,id)
			itemDao = ItemDao.new
			itemDao.getEquipData(playerId,id)
		end

		#获取宝物详细
		#@param [Integer] playerId,iid （宝物量表id）
		#@return [Hash]
		def self.getPropData(playerId,iid)
			itemDao = ItemDao.new
			itemDao.getPropData(playerId,iid)
		end


		#使用宝物 
		#@param [Integer,Integer,Integer] playerId,id,sort (1,2:批量)
		#@return
		def self.useProp(playerId,iid,sort)

		end

		#消耗装备
		#@param [Integer,Integer,Integer] playerId,id,count
		#@return
		def self.costEquip(playerId,iid,count)
			#TODO
		end

		#强化装备
		#@param [Integer,Integer] playerId,id
		#@return
		def self.forceEquip(playerId,id)
			#TODO
		end

	end

end