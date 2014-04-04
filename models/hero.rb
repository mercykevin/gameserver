module Model
	class Hero
		#招募英雄
		#@param [String,Hash,String]
		#@return [Hash]
		def self.recuritHero(player,recuritetype)
			#TODO random templete hero id
			templeteHeroId = 11001
			metaDao = MetaDao.instance
			commonDao = CommonDao.new
			heroDao = HeroDao.new
			templeteHero = metaDao.getHeroMetaData(templeteHeroId)
			if ! templeteHero
				return {:retcode => Const::ErrorCode::HeroRecuritTempleteHeroIsNotExist}
			end
			#空闲的英雄列表
			heroIdList = heroDao.getHeroIdList(player[:playerId])
			if heroIdList.length >= player[:freeheromax]
				return {:retcode => Const::ErrorCode::HeroRecuritLimitsUp}
			end
			#招募
			recruiteinfo = heroDao.getHeroRecruiteInfo(player[:playerId])
			consumetype = "time"
			lefttime = Time.now.to_i
			metaData = nil
			recruiteTime = nil
			case recuritetype
			when "normal"
				#普通招募验证有没有到冷却时间
				metaData = metaDao.getRecuriteMetaData("普通")
				recruiteTime = recruiteinfo[:recuritetime1]
			when "advanced"
				#高级招募
				metaData = metaDao.getRecuriteMetaData("高级")
				recruiteTime = recruiteinfo[:recuritetime2]
			else
				metaData = metaDao.getRecuriteMetaData("英雄令")
				recruiteTime = recruiteinfo[:recuritetime3]
			end
			if recruiteTime 
				lefttime = lefttime - recruiteTime
			end
			if lefttime < metaData.rFreeCooling.to_i
				#使用钻石招募
				consumetype = "diamond"
				if player[:diamond] < metaData.rCost.to_i
					return {:retcode => Const::ErrorCode::HeroRecuritDimondNotEnough}
				end
			end
			#创建英雄
			hero = createHero(templeteHero, player)
			#TODO need remove
			hero[:level] = 20
			hero[:exp] = 1000
			heroIdList << hero[:heroId]
			##
			if consumetype == "diamond"
				player[:diamond] = player[:diamond] - metaData.rCost.to_i
			else
				case recuritetype
				when "normal"
					recruiteinfo[:recuritetime1] = Time.new.to_i
				when "advanced"
					recruiteinfo[:recuritetime2] = Time.new.to_i
				else
					recruiteinfo[:recuritetime3] = Time.new.to_i
				end
				recruiteTime = Time.new.to_i
			end
			#更新相关信息到redis中
			heroIdListKey = Const::Rediskeys.getHeroListKey(player[:playerId])
			herokey = Const::Rediskeys.getHeroKey(hero[:heroId],player[:playerId])
			playerkey = Const::Rediskeys.getPlayerKey(player[:playerId])
			recruiteInfokey = Const::Rediskeys.getHeroRecruiteKey(player[:playerId])
			if consumetype == "diamond"
				commonDao.update({herokey => hero, heroIdListKey => heroIdList, playerkey => player})
			else
				commonDao.update({herokey => hero, heroIdListKey => heroIdList, recruiteInfokey => recruiteinfo})
			end
			#计算剩余时间，返回给前端
			lefttime = metaData.rFreeCooling.to_i - (Time.now.to_i - recruiteTime)
			lefttime = 0 unless lefttime >= 0
			{:retcode => Const::ErrorCode::Ok,:hero => hero,:lefttime=>lefttime,:recuritetype=>recuritetype}
		end
		#创建英雄信息 
		#@param [MetaData,Hash,Array] hero csv data,player info in Hash,
		#@return
		def self.createHero(templeteHero,player)
			heroDao = HeroDao.new
			#生成hero id
			heroId = heroDao.generateHeroId
			#创建hero
			hero = {}
			hero[:heroId] = heroId
			hero[:templeteHeroId] = templeteHero.generalID
			hero[:playerId] = player[:playerId]
			hero[:attack] = templeteHero.gInitialATK.to_f
			hero[:defend] = templeteHero.gInitialDEF.to_f
			hero[:intelegence] = 0
			hero[:blood] = templeteHero.gInitialHP.to_f
			#经验 
			hero[:exp] = 0
			#星级
			hero[:star] = templeteHero.gStart.to_i
			#级别
			hero[:level] = 1
			#英雄阶数
			hero[:adlevel] = 0
			#潜力
			hero[:capacity] = 0
			hero
		end
		#创建主将
		#@param [Integer,player]
		#@return [Hash]
		def self.registerMainHero(templeteHeroId,player)
			metaDao = MetaDao.instance
			commonDao = CommonDao.new
			heroDao = HeroDao.new
			templeteHero = metaDao.getHeroMetaData(templeteHeroId)
			if ! templeteHero
				return {:retcode => Const::ErrorCode::HeroRecuritTempleteHeroIsNotExist}
			end
			playerId = player[:playerId]
			#上阵的英雄列表
			heroIdList = heroDao.getBattleHeroIdList(playerId)
			if heroIdList != nil && heroIdList.length > 0
				return {:retcode => Const::ErrorCode::HeroRegisterFailHeroExist}
			end
			#创建英雄
			hero = createHero(templeteHero, player)
			heroIdList = Array.new(8) { Const::HeroLocked }
			heroIdList[0] = hero[:heroId]
			heroIdList[1] = Const::HeroEmpty
			#更新相关信息到redis中
			heroIdListKey = Const::Rediskeys.getBattleHeroListKey(playerId)
			herokey = Const::Rediskeys.getHeroKey(hero[:heroId], playerId)
			commonDao.update({herokey => hero, heroIdListKey => heroIdList })
			{:retcode => Const::ErrorCode::Ok,:hero => hero}
		end
		#get a hero info 
		#@param [Integer,Integer] hero id ,player id
		#@return [Hash]
		def self.getHero(heroId,playerId)
			heroDao = HeroDao.new
			heroDao.get(heroId,playerId)
		end
		#get battle hero list 
		#@param [Integer] player id
		#@return [Array]
		def self.getBattleHeroList(playerId)
			heroDao = HeroDao.new
			heroDao.getBattleHeroList(playerId)
		end
		#更换英雄
		#@param[Integer,Integer,Hash]
		#@return [Hash]
		def self.replaceHero(index,freeHeroId,player)
			GameLogger.debug("Model::Hero.replaceHero method params index:#{index},freeHeroId:#{freeHeroId}")
			commonDao = CommonDao.new
			heroDao = HeroDao.new
			#验证英雄是否存在
			if not heroDao.exist?(freeHeroId,player[:playerId])
				return {:retcode => Const::ErrorCode::Fail}
			end
			#上阵的英雄列表
			battleHeroIdList = heroDao.getBattleHeroIdList(player[:playerId])
			#空闲的英雄列表
			heroIdList = heroDao.getHeroIdList(player[:playerId])
			#数据非法
			if battleHeroIdList.include?(freeHeroId) or not heroIdList.include?(freeHeroId)
				return {:retcode => Const::ErrorCode::Fail}
			end
			#当前位置是锁住的位置，不能更换英雄
			battleHeroId = battleHeroIdList[index]
			if battleHeroId == Const::HeroLocked
				return {:retcode => Const::ErrorCode::Fail}
			end
			if battleHeroId == Const::HeroEmpty
				battleHeroIdList[index] = freeHeroId
			else
				if not heroDao.exist?(battleHeroId,player[:playerId])
					return {:retcode => Const::ErrorCode::Fail}
				end
				heroIdList << battleHeroId
				battleHeroIdList[index] = freeHeroId
			end
			heroIdList.delete(freeHeroId)
			#
			#验证都通的情况下
			battleHeroIdListKey = Const::Rediskeys.getBattleHeroListKey(player[:playerId])
			heroIdListKey = Const::Rediskeys.getHeroListKey(player[:playerId])
			commonDao.update({battleHeroIdListKey => battleHeroIdList, heroIdListKey => heroIdList })
			{:retcode => Const::ErrorCode::Ok}
		end
		#英雄传承
		#@param[Integer,Integer Hash]
		#@return [Hash]
		def self.transHero(heroId,freeHeroId,transtype,player)
			commonDao = CommonDao.new
			heroDao = HeroDao.new
			#上阵的英雄列表
			battleHeroIdList = heroDao.getBattleHeroIdList(player[:playerId])
			#空闲的英雄列表
			heroIdList = heroDao.getHeroIdList(player[:playerId])
			if battleHeroIdList.include?(heroId) && heroIdList.include?(freeHeroId)
				battleHero = heroDao.get(heroId,player[:playerId])
				freeHero = heroDao.get(freeHeroId,player[:playerId])
				if battleHero and freeHero
					if freeHero[:level] > 1 
						#处理英雄升级
						#TODO 要提供道具删除接口
						addExp = 0
						if transtype == 'normal'
							addExp = (freeHero[:exp]*0.6).to_i
						else
							addExp = freeHero[:exp]
						end
						heroDao.handleHeroLevelUp(battleHero, addExp)
						heroIdList.delete(freeHero[:heroId])
						#更新相关的redis数据
						battleHeroKey = Const::Rediskeys.getHeroKey(battleHero[:heroId],player[:playerId])
						freeHeroKey = Const::Rediskeys.getHeroKey(freeHero[:heroId],player[:playerId])
						heroIdListKey = Const::Rediskeys.getHeroListKey(player[:playerId])
						commonDao.update({battleHeroKey => battleHero, freeHeroKey => nil,heroIdListKey => heroIdList})
						{:retcode => Const::ErrorCode::Ok,:hero => battleHero}
					else
						{:retcode => Const::ErrorCode::Fail}
					end
				else
					{:retcode => Const::ErrorCode::Fail}
				end
			else
				{:retcode => Const::ErrorCode::Fail}
			end
		end
		#取空闲的英雄列表
		#@param[Integer]
		#@return [Array]
		def self.getHeroList(playerId)
			heroDao = HeroDao.new
			heroDao.getHeroList(playerId)
		end
		#取招募英雄的信息
		#@param[Integer]
		#@return [Hash]
		def self.getHeroRecruiteInfo(playerId)
			heroDao = HeroDao.new
			metaDao = MetaDao.instance
			heroDao.getHeroRecruiteInfo(playerId)
		end
		#武将阵位更换
		#@param[Integer,Intger,Integer]
		#@return [Hash]
		def self.arrangeBattleHero(firstIndex, secondIndex, playerId)
			playerDao = PlayerDao.new
			heroDao = HeroDao.new
			commonDao = CommonDao.new
			metaDao = MetaDao.instance
			if firstIndex == secondIndex
				{:retcode => Const::ErrorCode::Fail}
			else
				if firstIndex >= 0 && firstIndex < 8 && secondIndex >= 0 && secondIndex < 8
					#取玩家信息
					player = playerDao.getPlayer(playerId)
					#player level的配表数据
					playerLevelMeta = metaDao.getPlayerLevelMetaData(player[:level])
					#上阵的英雄列表
					battleHeroIdList = heroDao.getBattleHeroIdList(player[:playerId])
					#英雄布阵
					firstHeroId = battleHeroIdList[firstIndex]	
					secondHeroId = battleHeroIdList[secondIndex]
					if firstHeroId == Const::HeroLocked || secondHeroId == Const::HeroLocked
						{:retcode => Const::ErrorCode::Fail}
					else
						if firstHeroId == Const::HeroEmpty && secondHeroId == Const::HeroEmpty
							{:retcode => Const::ErrorCode::Fail}
						else
							battleHeroIdList[firstIndex] = secondHeroId
							battleHeroIdList[secondIndex] = firstHeroId
							battleHeroIdListKey = Const::Rediskeys.getBattleHeroListKey(player[:playerId])
							commonDao.update({battleHeroIdListKey => battleHeroIdList})
							{:retcode => Const::ErrorCode::Ok}
						end
					end
				else
					{:retcode => Const::ErrorCode::Fail}
				end
			end
		end
		# 英雄布阵，又来布所有的英雄，不是一一对换
		# @param[Array,Integer]
		# @return[Hash]
		def self.arrangeAllBattleHero(battleHeroIds, playerId)
			heroDao = HeroDao.new
			commonDao = CommonDao.new
			oldHash = {}
			newHash = {}
			#上阵的英雄列表
			oldBattleHeroIdList = heroDao.getBattleHeroIdList(playerId)
			#验证数据是否一至
			if battleHeroIds == nil or battleHeroIds.length != 8
				return {:retcode => Const::ErrorCode::Fail}
			else
				battleHeroIds.each_with_index do |heroId,index|
					if not oldBattleHeroIdList.include?(heroId)
						 return {:retcode => Const::ErrorCode::Fail}
					end
					if newHash.key?(heroId)
						newHash[heroId] = newHash[heroId] + 1
					else
						newHash[heroId] = 1
					end
				end
			end
			GameLogger.debug("Model::Hero.arrangeAllBattleHero step one check ok")
			#验证锁的位置是否一至
			oldBattleHeroIdList.each_with_index do |heroId,index|
				if heroId == Const::HeroLocked
					if battleHeroIds[index] != Const::HeroLocked
						return {:retcode => Const::ErrorCode::Fail}
					end
				end
				if oldHash.key?(heroId)
					oldHash[heroId] = oldHash[heroId] + 1
				else
					oldHash[heroId] = 1
				end
			end
			GameLogger.debug("Model::Hero.arrangeAllBattleHero step two check ok")
			#验证元素数量是否一至
			GameLogger.debug("Model::Hero.arrangeAllBattleHero oldHash:#{oldHash},newHash:#{newHash}")
			if not oldHash.eql?(newHash)
				return {:retcode => Const::ErrorCode::Fail}
			end
			GameLogger.debug("Model::Hero.arrangeAllBattleHero step three check ok")
			#验证都通的情况下
			battleHeroIdListKey = Const::Rediskeys.getBattleHeroListKey(playerId)
			commonDao.update({battleHeroIdListKey => battleHeroIds})
			{:retcode => Const::ErrorCode::Ok}
		end
		#英雄进阶
		#@param[Integer,Integer,Integer]
		#@return[Integer]
		def self.advancedHero(battleHeroId,freeHeroId,playerId)
			commonDao = CommonDao.new
			heroDao = HeroDao.new
			metaDao = MetaDao.instance
			#上阵的英雄列表
			battleHeroIdList = heroDao.getBattleHeroIdList(playerId)
			#空闲的英雄列表
			heroIdList = heroDao.getHeroIdList(playerId)
			if battleHeroIdList.include?(battleHeroId) && heroIdList.include?(freeHeroId)
				battleHero = heroDao.get(battleHeroId,playerId)
				freeHero = heroDao.get(freeHeroId,playerId)
				if battleHero and freeHero
					if battleHero[:templeteHeroId] == freeHero[:templeteHeroId]
						if battleHero[:adlevel] < metaDao.getMaxHeroAdvancedLevel
							heroAdancedMetaData = metaDao.getAdancedHeroLevelMetaData(battleHero[:adlevel] + 1)
							#增加相当属性
							GameLogger.debug("Model::Hero.advancedHero battle hero templete id:#{battleHero[:templeteHeroId]}")
							metaHero = metaDao.getHeroMetaData(battleHero[:templeteHeroId])
							startGrowth = heroAdancedMetaData.send("a#{metaHero.gStart.to_i}StarGrowth").to_i
							battleHero[:attack] = battleHero[:attack] + startGrowth
							battleHero[:defend] = battleHero[:defend] + startGrowth
							battleHero[:intelegence] = battleHero[:intelegence] + startGrowth
							battleHero[:blood] = battleHero[:blood] + startGrowth
							starCapacity = heroAdancedMetaData.send("a#{metaHero.gStart.to_i}StarPotential").to_i
							battleHero[:capacity] = battleHero[:capacity] + starCapacity
							battleHero[:adlevel] = battleHero[:adlevel] + 1
							heroIdList.delete(freeHero[:heroId])
							#更新相关的redis数据
							battleHeroKey = Const::Rediskeys.getHeroKey(battleHero[:heroId],playerId)
							freeHeroKey = Const::Rediskeys.getHeroKey(freeHero[:heroId],playerId)
							heroIdListKey = Const::Rediskeys.getHeroListKey(playerId)
							commonDao.update({battleHeroKey => battleHero, freeHeroKey => nil,heroIdListKey => heroIdList})
							{:retcode => Const::ErrorCode::Ok,:hero => battleHero}
						else
							{:retcode => Const::ErrorCode::Fail}
						end
					else
						{:retcode => Const::ErrorCode::Fail}
					end
				else
					{:retcode => Const::ErrorCode::Fail}
				end
			else
				{:retcode => Const::ErrorCode::Fail}
			end
		end
		#英雄培养
		#@param[Integer,Integer, Integer] 英雄Id, 角色Id
		#@return [Hash]
		def self.preBringupBattleHero(heroId, bringupType, playerId)
			commonDao = CommonDao.new
			heroDao = HeroDao.new
			metaDao = MetaDao.instance
			#上阵的英雄列表
			battleHeroIdList = heroDao.getBattleHeroIdList(playerId)
			#不在上阵列表中
			if not battleHeroIdList.include?(heroId)
				return {:retcode => Const::ErrorCode::Fail}
			end
			#英雄不存在
			battleHero = heroDao.get(heroId,playerId)
			if not battleHero
				return {:retcode => Const::ErrorCode::Fail}
			end
			#培养丹的数量
			bringupDrugCount = 5
			#所需金币数
			bringupGold = 0
			#培养配表
			bringupMetaData = metaDao.getHeroBringupMetaData(bringupType)
			#属性增减
			propsChange = Array.new(4, 0)
			#属性概率
			heroPropRates = [bringupMetaData.cATKProbability.to_i,bringupMetaData.cDEFProbability.to_i,
				bringupMetaData.cINTProbability.to_i,bringupMetaData.cHPProbability.to_i]
			#随机到一个增值索引
			addIndex = Utils::Random.randomIndex(heroPropRates)
			propsChange[addIndex] = bringupMetaData.cAttributeIncrease.to_i
			#将那个权重置为0
			heroPropRates[addIndex] = 0
			GameLogger.debug("Model::Hero.bringupBattleHero addIndex:#{addIndex}")
			#随机减值的索引
			reduceIndex = Utils::Random.randomIndex(heroPropRates)
			GameLogger.debug("Model::Hero.bringupBattleHero reduceIndex:#{reduceIndex}")
			#需要减值的属性
			propsChange[reduceIndex] = - bringupMetaData.cAttributeReduce.to_i
			#潜力消耗
			potentialConsumption = bringupMetaData.cPotentialConsumption.to_i
			times = 1
			case bringupType
			when Const::HeroBringUpNormal
				bringupDrugCount = 5
			when Const::HeroBringUpNormalTen
				bringupDrugCount = bringupDrugCount * 10
				times = 10
			when Const::HeroBringUpAdvanced
				bringupGold = 1
			when Const::HeroBringUpAdvancedTen
				bringupDrugCount = bringupDrugCount * 10
				bringupGold = 10
				times = 10
			else
			end
			potentialConsumption = potentialConsumption * times
			propsChange.each_with_index do |value,i|
				propsChange[i] = value * times
			end
			GameLogger.debug("Model::Hero.bringupBattleHero propsChange:#{propsChange.to_json}")
			{:retcode => Const::ErrorCode::Ok, :propschange => propsChange}
		end
		# 英雄培养确认
		#
		#
		def self.bringupBattleHero(heroId, bringupType, playerId)
			
		end

	end # class
end # model definition
