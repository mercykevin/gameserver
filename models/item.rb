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
				return {:retcode => Const::ErrorCode::Fail}
			end
			#数量非法
			if ! ( count && count.is_a?(Integer) && count > 0 )
				GameLogger.debug("Model::Item.addItem method params count:#{count} => count is illege !")
				return {:retcode => Const::ErrorCode::Fail}
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
					propData[:iid] = tempItem.propID.to_i
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
				equipHash = Hash.new
				#添加到未装备列表 ，类型
				equipIdList = itemDao.getEquipUnusedIdList(playerId , tempItem.eType)
				for i in 1..count do
					#兵法
					if tempItem.eType == Const::ItemTypeBook
						equip = {}
						equip[:id] = RedisClient.incr(Const::Rediskeys.getEquipIdAutoIncKey())
						equip[:iid] = tempItem.bookID.to_i
						equip[:star] = tempItem.bStar.to_i
						equip[:level] = tempItem.bLevel.to_i
						equip[:createdAt] = Time.now.to_i
						equip[:updatedAt] = Time.now.to_i
					#装备类	
					else
						equip = {}
						equip[:id] = RedisClient.incr(Const::Rediskeys.getEquipIdAutoIncKey())
						equip[:iid] = tempItem.equipmentID.to_i
						equip[:star] = tempItem.eStar.to_i
						equip[:level] = tempItem.elevel.to_i
						equip[:type] = tempItem.eType.to_i
						equip[:attack] = tempItem.eATK.to_i
						equip[:defence] = tempItem.eDEF.to_i
						equip[:blood] = tempItem.eHP.to_i
						equip[:createdAt] = Time.now.to_i
						equip[:updatedAt] = Time.now.to_i
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
		#@param [Hash,Integer] playerId,id 装备id
		#@return [Hash]
		def self.strengthenEquip(player,id)
			playerId = player[:playerId]
			itemDao = ItemDao.new
			exists = itemDao.exist?(playerId,id)
			#装备存在
			if not exists
				return {:retcode => Const::ErrorCode::StrengthenEquipIsNotExist}
			end
			metaDao = MetaDao.instance
			equipData = itemDao.getEquipData(playerId,id)
			#已是最高级
			maxLevel = metaDao.getEquipMaxLevel
			if  equipData[:level] >= maxLevel
				return {:retcode => Const::ErrorCode::StrengthenEquipIsTheHighestLevel}
			end
			beforeLevel = equipData[:level]
			equipTemp = metaDao.getTempItem(equipData[:iid])
			#银币消耗
			strengthenTemp = metaDao.getStrengthenMetaData(beforeLevel , equipData[:star])
			siliverCost = 0
			case equipTemp.eType.to_i
			when Const::ItemTypeWeapon
				siliverCost = strengthenTemp.eWeaponSpend.to_i
			when Const::ItemTypeShield
				siliverCost = strengthenTemp.eArmorSpend.to_i
			when Const::ItemTypeHorse
				siliverCost = strengthenTemp.eHorseSpend.to_i
			else
				GameLogger.debug("Model::Item.strengthen method params id:#{id} ,iid:#{equipTemp.iid} ,type:#{equipTemp.eType} , it's not a equipment !")
				return {:retcode => Const::ErrorCode::Fail}
			end
			#银币不足
			if player[:siliver].to_i < siliverCost
				return {:retcode => Const::ErrorCode::siliverIsNotEnough}
			end
			#消耗银币
			#player[:siliver] = player[:siliver].to_i - siliverCost
			player = Model::Player.addSiliver(player , - siliverCost , FunctionConst::EquipStrengthen)
			#处理强化后的升级
			vipMetaData = metaDao.getVipMetaData(player[:vip])
			rates = vipMetaData.vCritProbability.split(",")
			levelUp = Utils::Random::randomIndex(rates) + 1		
			equipData[:level] = beforeLevel + levelUp
			equipData[:updatedAt] = Time.now.to_i
			#处理强化效果
			case equipTemp.eType.to_i
			when Const::ItemTypeWeapon
				equipData[:attack] = equipTemp.eATK.to_i + (equipData[:level]  - 1) * equipTemp.eATKUP.to_i
			when Const::ItemTypeShield
				equipData[:defence] = equipTemp.eDEF.to_i + (equipData[:level]  - 1) * equipTemp.eDEFUP.to_i
			when Const::ItemTypeHorse
				equipData[:blood] = equipTemp.eHP.to_i + (equipData[:level]  - 1) * equipTemp.eHPUP.to_i
			else
				return {:retcode => Const::ErrorCode::Fail}
			end
			#保存
			commonDao = CommonDao.new
			playerKey = Const::Rediskeys.getPlayerKey(playerId)
			equipKey = Const::Rediskeys.getEquipKey(playerId,equipData[:id])
			commonDao.update(playerKey => player , equipKey => equipData)
			GameLogger.debug("Model::Item.strengthen  playerId:#{playerId} , equipId:#{id} , equipIid:#{equipData[:iid]} , before level #{beforeLevel} after level  #{equipData[:level]}! ")
			{equipKey => equipData }
		end

		#强化进阶
		#@param [Hash,Integer] playerId,id 兵法id
		#@return [Hash]
		def self.advanceBook(player , id)
			# playerId = player[:playerId]
			# itemDao = ItemDao.new
			# exists = itemDao.exist?(playerId,id)
			# #装备存在
			# if not exists
			# 	return {:retcode => Const::ErrorCode::StrengthenEquipIsNotExist}
			# end
			# metaDao = MetaDao.instance
			# equipData = itemDao.getEquipData(playerId,id)
			# #已是最高级
			# maxLevel = metaDao.getEquipMaxLevel
			# if  equipData[:level] >= maxLevel
			# 	return {:retcode => Const::ErrorCode::StrengthenEquipIsTheHighestLevel}
			# end
			# GameLogger.debug("Model::Item.advance  playerId:#{playerId} , bookId:#{id} , equipIid:#{equipData[:iid]} , before level #{beforeLevel} after level  #{equipData[:level]}! ")

		end




	end

end