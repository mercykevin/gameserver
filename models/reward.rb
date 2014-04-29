module Model
	#处理奖励串
	#不考虑每个格子的上限了
	class Reward
		#验证背包格子
		#返回格子是否满  满：true
		#@param [Integer,Hash] 玩家id，道具列表 如：{""500001"":1,""410104"":2,""200001"":3} 
		#@return [Boolean] 是否满 
		def self.isBackpackFull(playerId , awardStrs)
			awardStrs = JSON.parse(awardStrs) 
			if not awardStrs
				return false
			end
			itemCount = []
			awardStrs.each do |item|
			
			end

			if false
				return Const::ErrorCode::BackpackIsFull
			end
		end
		#处理奖励
		#配置json格式，同一类型的放一起
		#如："{""siliver"":100,""dimond"":500,""item"":{""500001"":1,""410104"":2,""200001"":3} , ""hero"":{""300001"":2,""400001"":10} ,""soul"":{""2000"":5}}"
		#@param [Hash,String,String]
		#@return [Hash] 
		def self.processAward(player , awardStrs , function)
			if not awardStrs or awardStrs.empty?
				GameLogger.error("Model::Reward.processAward method params awardStrs:#{awardStrs} , awardStrs is empty !")
				return 
			end
			playerId = player[:playerId]
			#背包已满 
		 	isFull = isBackpackFull(playerId , awardStrs)
		 	if isFull
		 		raise Const::ErrorCode.BackpackIsFull
		 	end
		 	retHash = {}
		 	#处理奖励
			awardList = JSON.parse(awardStrs) 
			awardList.each do |rewardType,awards|
				case rewardType.to_s
				#钻石
				when Const::RewardTypeDimond
					Model::Player.addDiamond(player , awards , function)
					playerKey = Const::Rediskeys.getPlayerKey(playerId)
					retHash[playerKey] = player
				#银币
				when Const::RewardTypeSiliver
					Model::Player.addSiliver(player , awards , function)
					playerKey = Const::Rediskeys.getPlayerKey(playerId)
					retHash[playerKey] = player
				#道具类
				when Const::RewardTypeItem
					awards.each do |iid,count|
						itemRet = Model::Item.addItemNoSave(player , iid , count)
						dataHash = itemRet[:dataHash]
						retHash = retHash.merge(dataHash)
					end
				#武将类
				when Const::RewardTypeHero
				#将魂
				when Const::RewardTypeSoul
				else
					GameLogger.error("Model::Reward.processAward awardStrs:#{awardStrs} , unhandle award type '#{rewardType}' !")
				end
			end
			GameLogger.info("Model::Reward.processAward playerId:#{playerId} , retHash:#{retHash} ,function '#{function}'' !")
			retHash 
		end

	end
end
