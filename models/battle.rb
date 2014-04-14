module Model
	class Battle
		# 取战役子列表
		# @param [Integer]
		# @return [Array]
		def self.getSubBattleList(battleId, playerId)
			subBattleList = []
			metaDao = MetaDao.instance
			battleDao = BattleDao.new
			#所有子战役的配表信息
			subBattleMetaList = metaDao.getSubBattleListById(battleId)
			#玩家战役信息
			subBattleHash = battleDao.getSubBattleInfoMap(battleId, playerId)
			#遍利配置信息
			subBattleMetaList.each do |battleMetaData|
				battleInfo = {}
				battleInfo[:subbattleid] = battleMetaData.bSubID
				battleInfo[:npcname] = battleMetaData.bNPCName
				battleInfo[:npcdes] = battleMetaData.bSubDesc
				battleInfo[:getheroxp] = battleMetaData.bGEXP
				battleInfo[:maxtimes] = battleMetaData.bResetTimes
				battleInfo[:stars] = 0
				battleInfo[:times] = 0
				battleInfo[:win] = false
				#没有打过
				battleInfo[:turndown] = false
				playerBattleInfo = subBattleHash[battleMetaData.bSubID.to_sym]
				if playerBattleInfo
					#玩的信息存在
					battleInfo[:stars] = playerBattleInfo[:stars]
					battleInfo[:times] = playerBattleInfo[:times]
					battleInfo[:win] = playerBattleInfo[:win]
					#代表已经打过
					battleInfo[:turndown] = true
				end
				subBattleList << battleInfo
			end
			subBattleList
		end
		# 推图
		# @param[String,Integer]
		# @return[Hash]
		def self.pve(subBattleId,playerId)
			#战役dao
			metaDao = MetaDao.instance
			battleDao = BattleDao.new
			commonDao = CommonDao.new
			#对应的战役不存在
			metaBattleData = metaDao.getSubBattleMetaData(subBattleId)
			if not metaBattleData
				return {:retcode => Const::ErrorCode::Fail}
			end
			#取玩家玩过的战役
			playerSubBattleMap = battleDao.getSubBattleInfoMap(metaBattleData.battlefirstID, playerId)
			if not playerSubBattleMap.key?(metaBattleData.bSubID.to_sym)
				#玩家没有打过这个战役
				#1 先验证是否打掉了上一场大战役的最后一场
				battleIdList = metaDao.getBattleIdList
				battleIndex = battleIdList.index(metaBattleData.battlefirstID)
				if battleIndex == 0
					#第一场战役，那就不要验证是否赢了上一场的最后一个战役
				else
					#上一场大战役id
					lastBattleId = battleIdList[battleIndex - 1]
					lastPlayerSubBattleMap = battleDao.getSubBattleInfoMap(lastBattleId, playerId)
					#最后一场战役
					lastSubBattleMetaData = metaDao.getSubBattleListById(lastBattleId)[-1]
					if not checkTurnDownBattle(playerSubBattleMap, lastSubBattleMetaData)
						return {:retcode => Const::ErrorCode::Fail}
					end
				end
				#2 是否打掉了小战役的上一场
				index = nil
				subBattleList = metaDao.getSubBattleListById(metaBattleData.battlefirstID)
				subBattleList.each_with_index do |tmpBattle,i|
					if tmpBattle.bSubID == metaBattleData.bSubID
						index = i
						break;
					end
				end
				if index == nil
					return {:retcode => Const::ErrorCode::Fail}
				else
					if index > 0
						if not checkTurnDownBattle(playerSubBattleMap, subBattleList[index - 1])
							return {:retcode => Const::ErrorCode::Fail}
						end
					end
				end
			end
			#验证都通过话，打战役
			#TODO need add fight logic
			pveBattleInfo = playerSubBattleMap[metaBattleData.bSubID.to_sym]
			if pveBattleInfo
				pveBattleInfo[:win] = true
				pveBattleInfo[:times] = pveBattleInfo[:times] + 1
				pveBattleInfo[:time] = Time.now().to_i
				pveBattleInfo[:stars] = 3
			else
				pveBattleInfo = {}
				pveBattleInfo[:battleid] = metaBattleData.bSubID
				pveBattleInfo[:win] = false
				pveBattleInfo[:times] = 1
				pveBattleInfo[:time] = Time.now().to_i
				pveBattleInfo[:stars] = 0
				playerSubBattleMap[metaBattleData.bSubID.to_sym] = pveBattleInfo
			end
			#add battleId to list
			addRet = battleDao.addBattleIdToList(metaBattleData.bSubID,playerId)
			key = Const::Rediskeys.getBattleListKey(metaBattleData.battlefirstID, playerId)
			commonDao.update({key => playerSubBattleMap}.merge(addRet))
			#返回值
			{:retcode => Const::ErrorCode::Ok,:battleinfo => pveBattleInfo}
		end
		# 验证是否推掉这个图
		# @param [Hash,MetaData]
		# @return [Bool]
		def self.checkTurnDownBattle(playerBattleMap, subBattleMeta)
			if playerBattleMap.key?(subBattleMeta.bSubID.to_sym)
				battleInfo = playerBattleMap[subBattleMeta.bSubID]
				battleInfo[:win]
			else
				false
			end
		end
		#获取战役大类列表
		# @param nothing
		# @return [Array]
		def self.getBattleList
			metaDao = MetaDao.instance
			metaDao.getBattleList
		end
		#取玩家打到的最后一场战役id
		# @param[Integer] playerId
		# @return[String]
		def self.getLastBattleId(playerId)
			battleDao = BattleDao.new
			list = battleDao.getBattleIdList(playerId)
			if list.length > 0 
				list[-1]
			else
				nil
			end
		end
	end # end class
end # end model