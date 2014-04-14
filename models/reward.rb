module Model
	#处理奖励串
	#不考虑每个格子的上限了
	class Reward

		#验证背包格子
		#返回格子是否满  满：true
		def self.validatePackage(playerId , awardStrs)
			if false
				return Const::ErrorCode::BackpackIsFull
			end
		end

		#处理奖励
		#配置json格式，同一类型的放一起
		#如：{siliver:100 , gold:500 , item:[{"500001":1},{"400001":2},{"200001":3}] , hero:[{"300001":2},{"400001":10}] ,soul:[{"2000":5}]}
		def self.processAward(player , awardStrs , function)
			if not awardStrs or awardStrs.empty?
				GameLogger.error("Model::Reward.processAward method params awardStrs:#{awardStrs} , awardStrs is empty !")
				return 
			end
			playerId = player[:playerId]
			#背包已满 TODO
		 	isFull = validatePackage(playerId , awardStrs)
		 	if isFull
		 		return Const::ErrorCode.BackpackIsFull
		 	end
		 	retHash = {}
		 	#处理奖励
			awardList = JSON.parse(awardStrs, {:symbolize_names => true}) 
			awardList.each_key do |rewardType|
				awards = awardList[rewardType]
				puts "key #{rewardType}  awards:#{awards} #{Const::RewardTypeDimond} #{ rewardType == Const::RewardTypeDimond	}  "
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
					awards.each do |itemIidCount|
						itemIid = 
						count = awards[itemIidCount]
						itemRet = Model::Item.addItemNoSave(playerId , itemIid , count)
						#retHash.merge(itemRet)
					end
				#武将类
				when Const::RewardTypeHero
				#将魂
				when Const::RewardTypeSoul
				else
					GameLogger.error("Model::Reward.processAward awardStrs:#{awardStrs} , unhandle award type '#{rewardType}' !")
				end
				puts "retHash - - - - - -#{retHash}"
			end

			GameLogger.error("Model::Reward.processAward playerId:#{playerId} , awardStrs:#{awardStrs} ,function #{function} !")
			retHash 
		end

	end
end
