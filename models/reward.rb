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
		#如：{hero:[1,2,3] , prop:[1,2,3] , equip:[1,2,3] , siliver , gold}
		def self.processAward(player , awardStrs)
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
		 	#处理奖励
			awardList = JSON.parse(awardStrs, {:symbolize_names => true}) 
			#TODO
			awardArr.each_key do |rewardType|
				case rewardType
				#钻石
				when Const::RewardTypeDimond
				#银币
				when Const::RewardTypeSiliver
				#道具类
				when Const::RewardTypeItem 
				#武将类
				when Const::RewardTypeHero
				#将魂
				when Const::RewardTypeSoul
				else
					GameLogger.error("Model::Reward.processAward awardStrs:#{awardStrs} , unhandle award type '#{rewardType}' !")
				end
			end
			GameLogger.error("Model::Reward.processAward playerId:#{playerId} , awardStrs:#{awardStrs} !")
			ret 
		end

	end
end
