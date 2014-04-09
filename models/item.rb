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

		#
		#添加道具 , 没有保存
		#1：武器防具坐骑兵法
		#2：宝物
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
						equip[:type] = tempItem.eType.to_i
						#5个兵法进阶失败的次数
						equip[:failTimes] = 0
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
						#init 智力 TODO
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

		#获取装备详细 （武器防具坐骑兵法）
		#@param [Integer] playerId,id
		#@return [Hash]
		def self.getEquipAllData(playerId,id)
			itemDao = ItemDao.new
			itemDao.getEquipAllData(playerId,id)
		end


		#获取装备信息 武器防具坐骑
		def self.getEquipmentData(playerId,id)
			itemDao = ItemDao.new
			itemDao.getEquipmentData(playerId,id)
		end

		#获取兵法信息
		def self.getBookData(playerId,id)
			itemDao = ItemDao.new
			itemDao.getBookData(playerId,id)
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
			metaDao = MetaDao.instance
			equipData = itemDao.getEquipmentData(playerId,id)
			#装备不存在
			if not equipData
				return {:retcode => Const::ErrorCode::EquipmentIsNotExist}
			end
			#已是最高级
			maxLevel = metaDao.getEquipMaxLevel
			if  equipData[:level] >= maxLevel
				return {:retcode => Const::ErrorCode::LevelIsTheHighest}
			end
			beforeLevel = equipData[:level]
			#银币消耗
			strengthenTemp = metaDao.getStrengthenMetaData(beforeLevel , equipData[:star])
			siliverCost = 0
			equipTemp = metaDao.getEquipMetaData(equipData[:iid])
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
			#保存
			commonDao = CommonDao.new
			playerKey = Const::Rediskeys.getPlayerKey(playerId)
			equipKey = Const::Rediskeys.getEquipKey(playerId,equipData[:id])
			commonDao.update(playerKey => player , equipKey => equipData)
			GameLogger.debug("Model::Item.strengthen  playerId:#{playerId} , equipId:#{id} , equipIid:#{equipData[:iid]} , before level #{beforeLevel} after level  #{equipData[:level]}! ")
			{:retcode => Const::ErrorCode::Ok,:equipdata => equipData }
		end

		#返回装备的加成值
		#@param [Integer , Integer] 装备iid，装备等级
		#@return [Integer]
		def self.calcEquipBuff(iid , level)
			metaDao = MetaDao.instance
			equipTemp = metaDao.getEquipMetaData(iid)
			case equipTemp.eType.to_i
			when Const::ItemTypeWeapon #attack
				return equipTemp.eATK.to_i + (level - 1) * equipTemp.eATKUP.to_i
			when Const::ItemTypeShield #defence
				return equipTemp.eDEF.to_i + (level - 1) * equipTemp.eDEFUP.to_i
			when Const::ItemTypeHorse #blood
				return equipTemp.eHP.to_i + (level - 1) * equipTemp.eHPUP.to_i
			else
				raise "is not equip : #{Const::ErrorCode::Fail}"
			end
		end

		#处理强化效果
		#伤害：返回加的值
		#其他加成比率返回 小数
		#@param [Integer , Integer] 装备iid，装备等级
		#@return [Float] 返回 加成比率 ， 
		def self.calcBookBuff(iid , level)
			metaDao = MetaDao.instance
			bookTemp = metaDao.getBookMetaData(iid)
			buff = 0
			#加伤害 - 伤害 加值
			if bookTemp.bHurt
				return bookTemp.bHurt.to_i + (level-1) * bookTemp.bHurtUP.to_i
			#其他 -加百分比
			else
				#加攻击
				if bookTemp.bATKProportion
					buff = bookTemp.bATKProportion.to_i + (level-1) * bookTemp.bATKUP.to_i
				#加防御
				elsif bookTemp.bDEFProportion 
					buff = bookTemp.bDEFProportion.to_i + (level-1) * bookTemp.bDEFUP.to_i
				#加智力
				elsif bookTemp.bINTProportion
					buff = bookTemp.bINTProportion.to_i + (level-1) * bookTemp.bINTUP.to_i
				else
					raise "is not book : #{Const::ErrorCode::Fail}"
				end
				#返回加成比率，小数
				buff / 100.to_f
			end
		end

		#重置兵法进阶失败次数 除了 bookId
		#@param [Integer] bookId
		#@return
		def self.resetBookAdvanceFailTimes(bookId)
			GameLogger.info("Model::Item.resetBookAdvanceFailTimes reset all book advance fail times ! ")
			#TODO 要取出所有兵法
		end


		#兵法进阶
		#  	进阶成功就清掉所有兵法的失败次数
		# 	进阶失败并且是5本书，累计失败次数,清掉其他所有兵法的失败次数
		#@param [Hash,Integer,Array] playerId,id 兵法id ,兵法列表
		#@return [Hash]
		def self.advanceBook(player , id, bookIds)
			metaDao = MetaDao.instance
			itemDao = ItemDao.new
			playerId = player[:playerId]
			bookPreData = {}
			begin
				bookPreData = preAdvanceBook(player, id ,bookIds)
			rescue
				retcode = "#{$!}"
				GameLogger.debug("Model::Item.advanceBook  playerId:#{playerId} , bookId:#{id} , bookIid:#{bookPreData[:bookData][:iid]} , preAdvanceBook retcode:#{retcode}! ")
				return {:retcode => retcode}
			ensure
				#finally
			end
			#成功率 千分比
			rate = bookPreData[:successrate] 
			siliverCost = bookPreData[:siliver]
			bookData = bookPreData[:bookdata]
			bookIdArr = bookPreData[:bookIdArr]
			#进阶成功
			bookFragmentData = nil
			bookFragmentKey = nil
			advSucc = rand(1000) < rate
			if advSucc
				bookData[:level] += 1
				bookData[:failTimes] = 0
			else
				#失败，超过5本书，记录失败次数
				bookCount = metaDao.getFlagValue(FlagConstKey::BookAdvanceUpSuccRateMaxBookCount).to_i
				if bookIdArr.length >= bookCount
					bookData[:failTimes] += 1
				else
					bookData[:failTimes] = 0
				end
				#获得碎片
				randBookId = bookIds[rand(bookIds.length)]
				useBookData = itemDao.getBookData(playerId,id)
				useBookTemp = metaDao.getBookMetaData(useBookData[:iid])
				if useBookTemp.bFragment
					bookFragArr = useBookTemp.bFragment.split(",")
					awardBookFragIid = bookFragArr[rand(bookFragArr.length)]
					bookFragment = metaDao.getBookFragmentMetaData(awardBookFragIid)
					if bookFragment
						bookFragmentData = awardBookFragment(playerId,bookFragment.fragmentID)
					else
						raise "book iid '#{id}' have no found book fragment iid '#{awardBookFragIid}'"
					end
				end
			end
			#所有兵法的进阶的失败次数重置
			resetBookAdvanceFailTimes(id)
			#消耗银币
			player = Model::Player.addSiliver(player , - siliverCost , FunctionConst::BookAdvance)
			playerKey = Const::Rediskeys.getPlayerKey(playerId)
			bookKey = Const::Rediskeys.getEquipKey(playerId,id)
			commonDao = CommonDao.new
			#成功
			if advSucc
				commonDao.update(playerKey => player , bookKey => bookData)
				GameLogger.info("Model::Item.advanceBook  playerId:#{playerId} , bookId:#{id} , bookIid:#{bookData[:iid]} ，advance success ! after level:#{bookData[:level]}! ")
				return {:retcode => Const::ErrorCode::Ok , :result => Const::BookAdvanceSuccess , :bookdata => bookData }
			else
				bookFragmentKey = Const::Rediskeys.getBookFragmentKey(playerId,bookFragmentData[:iid])	
				commonDao.update(playerKey => player , bookFragmentKey => bookFragmentData)
				GameLogger.info("Model::Item.advanceBook  playerId:#{playerId} , bookId:#{id} , bookIid:#{bookData[:iid]} ，advance fail ! award book fragment iid:#{bookFragmentData[:iid]}  ")
 				return {:retcode => Const::ErrorCode::Ok , :result => Const::BookAdvanceFail }
 			end
		end

		#获得兵法碎片
		#@param [Integer,Integer] 玩家id，碎片id
		#@return [Hash]
		def self.awardBookFragment(playerId,bookFragIid)
			itemDao = ItemDao.new
			bookFragmentKey = Const::Rediskeys.getBookFragmentKey(playerId,bookFragIid)
			bookFragmentData  = itemDao.getBookFragmentData(playerId,bookFragmentKey)
			if bookFragmentData
				bookFragmentData[:count] += 1
				bookFragmentData[:updatedAt] = Time.now.to_i
			else
				bookFragmentData = {}
				bookFragmentData[:id] = RedisClient.incr(Const::Rediskeys.getBookFragmentIdtoIncKey())
				bookFragmentData[:iid] = bookFragIid
				bookFragmentData[:count] = 1
				bookFragmentData[:createdAt] = Time.now.to_i
				bookFragmentData[:updatedAt] = Time.now.to_i
			end
			GameLogger.info("Model::Item.awardBookFragment playerId:#{playerId} ,gain book fragment iid :#{bookFragIid}")
			bookFragmentData
		end

		#兵法进阶预览借口
		#@param [Hash,Integer,Array] playerId,id 兵法id ,兵法列表
		#@return [Hash] successRate:成功率（如50）
		def self.preAdvanceBookService(player , id , bookIds)
			playerId = player[:playerId]
			result = {}
			begin
				result = preAdvanceBook(player, id ,bookIds)
			rescue
				retcode = $!
				GameLogger.info("Model::Item.preAdvanceBookService playerId:#{playerId} , bookId:#{id} , bookIds:#{bookIds} error:#{retcode}")
				# puts $@  
				return {:retcode => "#{retcode}" }
			ensure
				#finally
			end
			#千分比 转化成 百分比数值 小数四舍五入
			rate = (result[:successrate].to_i / 10 ).round()
			result[:successrate] = rate
			result.delete(:bookdata)
			result.delete(:bookIdArr)
			#返回概率，消耗银币数量
			result
		end

		#兵法进阶预览
		#@param [Hash,Integer,Array] playerId,id 兵法id ,兵法列表
		#@return [Hash] successRate:成功率（如50）
		def self.preAdvanceBook(player , id , bookIds)
			playerId = player[:playerId]
			itemDao = ItemDao.new
			#没有选择兵法来祭祀
			if bookIds and bookIds.to_s.empty?
				raise Const::ErrorCode::BookAdvancedNoBooksChoosed.to_s
			end
			#银币不足
			metaDao = MetaDao.instance
			bookData = itemDao.getBookData(playerId,id)
			#兵法不存在
			if not bookData
				raise  Const::ErrorCode::BookAdvancedNoTargetBook.to_s
			end
			bookTemp = metaDao.getBookMetaData(bookData[:iid])
			#已是最高级
			maxLevel = metaDao.getBookMaxLevel
			if  bookData[:level] >= maxLevel
				raise Const::ErrorCode::LevelIsTheHighest.to_s
			end
			#进阶配置
			bookAdvanceTemp = metaDao.getBookAdvancedMetaData(bookData[:level],bookData[:star])
			#银币不足
			if player[:siliver] < bookAdvanceTemp.bSpendMoney.to_i
				raise Const::ErrorCode::SilverIsNotEnough.to_s
			end
			#选择的兵法验证
			rateSumUp = 0
			bookIdArr = bookIds.split(",")
			#自己进阶自己
			if bookIdArr.include?(id.to_s)
				GameLogger.debug("Model::Item.preAdvanceBook playerId:#{playerId} , book id:#{id} bookIds:'#{bookIds}', cannont advance book use itself book !")
				raise Const::ErrorCode::Fail.to_s
			end
			bookIdArr.each do |bookId| 
				useBookData = itemDao.getBookData(playerId,bookId)
				#兵法不存在 , 兵法已上阵 (上阵兵法将从装备列表中移除!)
				if not useBookData
					GameLogger.debug("Model::Item.advance playerId:#{playerId} , book id:#{bookId} is not exist !")
					raise Const::ErrorCode::BookIsNotExist.to_s
				end
				useBookTemp = metaDao.getBookMetaData(bookData[:iid])
				#自带兵书不能祭祀 TODO
				isSelfBook = metaDao.getSelfBookList.include?(useBookTemp.bookID.to_i)
				if isSelfBook
					raise Const::ErrorCode::BookIsHeroSelf.to_s
				end
				#进阶配置
				upBookAdvanceTemp = metaDao.getBookAdvancedMetaData(useBookData[:level],useBookData[:star])
				#每个兵法提升的成功率
 				rateSumUp += upBookAdvanceTemp.bSuccessrateUP.to_f
			end
			#得到千分比 成功率 如50%0，这里得到 50 ，因为5本书失败后提升概率为千分比
			rate = ( rateSumUp / bookAdvanceTemp.bNeedSuccessrate.to_i * 1000).to_i
			if rate > 1000
				rate = 1000
			end
			bookCount = metaDao.getFlagValue(FlagConstKey::BookAdvanceUpSuccRateMaxBookCount).to_i
			#5本书的话，根据失败次数提升成功率
			if bookIdArr.length >= bookCount
				rate += bookAdvanceTemp.bFailureIncrease.to_i * bookData[:failTimes]
			end
			GameLogger.debug("Model::Item.preAdvanceBook  playerId:#{playerId} , bookId:#{id} , bookIid:#{bookData[:iid]} ,use bookIds:#{bookIds} , advance succ_rate:'#{rate}%。' )")
 			#成功率，千分比，contrller转换为百分比给前端
 			{:successrate => rate , :siliver => bookAdvanceTemp.bSpendMoney.to_i , :bookdata => bookData , :bookIdArr => bookIdArr}
		end

		#上阵兵法 TODO ，兵法记录在武将身上，上阵后从兵法列表中删掉该兵法

	end

end