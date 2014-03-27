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
			hero = createHero(templeteHero, player, heroIdList)
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
			{:retcode => Const::ErrorCode::Ok,:hero => hero,:lefttime=>lefttime}
		end
		#get a hero info 
		#@param [MetaData,Hash,Array] hero csv data,player info in Hash,
		#@return
		def self.createHero(templeteHero,player,heroIdList)
			heroDao = HeroDao.new
			#生成hero id
			heroId = heroDao.generateHeroId
			#创建hero
			hero = {}
			hero[:heroId] = heroId
			hero[:templeteHeroId] = templeteHero.GeneralID
			hero[:playerId] = player[:playerId]
			hero[:attack] = templeteHero.gInitialATK.to_f
			hero[:defend] = templeteHero.gInitialDEF.to_f
			hero[:intelegence] = 0
			hero[:blood] = templeteHero.gInitialHP.to_f 
			hero[:exp] = 0
			hero[:star] = templeteHero.gStart.to_i
			hero[:level] = 1
			heroIdList << heroId
			hero
		end
		#register main hero
		#@param 
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
			hero = createHero(templeteHero, player, heroIdList)
			#更新相关信息到redis中
			heroIdListKey = Const::Rediskeys.getBattleHeroListKey(playerId)
			herokey = Const::Rediskeys.getHeroKey(hero[:heroId],playerId)
			commonDao.update({herokey => hero, heroIdListKey => heroIdList })
			{:retcode => Const::ErrorCode::Ok,:hero => hero}
		end
		#get a hero info 
		#@param [Integer,Integer] hero id ,player id
		#@return [Hash]
		def self.getHero(heroId,playerId)
			heroDao = HeroDao.new
			heroDao.get(heroid,playerId)
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
		def self.replaceHero(heroId,freeHeroId,player)
			commonDao = CommonDao.new
			heroDao = HeroDao.new
			#上阵的英雄列表
			battleHeroIdList = heroDao.getBattleHeroIdList(player[:playerId])
			#空闲的英雄列表
			heroIdList = heroDao.getHeroIdList(player[:playerId])
			if battleHeroIdList.include?(heroId) && heroIdList.include?(freeHeroId)
				if heroDao.exist?(heroId,player[:playerId]) && heroDao.exist?(freeHeroId,player[:playerId])
					index = battleHeroIdList.index(heroId)
					battleHeroIdList[index] = freeHeroId
					heroIdList.delete(freeHeroId)
					heroIdList << heroId
					battleHeroIdListKey = Const::Rediskeys.getBattleHeroListKey(player[:playerId])
					heroIdListKey = Const::Rediskeys.getHeroListKey(player[:playerId])
					commonDao.update({battleHeroIdListKey => battleHeroIdList, heroIdListKey => heroIdList })
					{:retcode => Const::ErrorCode::Ok}
				else
					{:retcode => Const::ErrorCode::Fail}
				end
			else
				{:retcode => Const::ErrorCode::Fail}
			end
		end
		#英雄上阵
		def self.batleHero(freeHeroId, playerId)
			commonDao = CommonDao.new
			heroDao = HeroDao.new
			metaDao = MetaDao.instance
			playerDao = PlayerDao.new
			#取玩家信息
			player = playerDao.getPlayer(playerId)
			#上阵的英雄列表
			battleHeroIdList = heroDao.getBattleHeroIdList(player[:playerId])
			#player level的配表数据
			playerLevelMeta = metaDao.getPlayerLevelMetaData(player[:level])
			if battleHeroIdList.length < playerLevelMeta.cArrayPositionNumber.to_i
				#空闲的英雄列表
				heroIdList = heroDao.getHeroIdList(player[:playerId])
				if heroIdList.include?(freeHeroId) and heroDao.exist?(freeHeroId,player[:playerId])
					battleHeroIdList << freeHeroId
					heroIdList.delete(freeHeroId)
					battleHeroIdListKey = Const::Rediskeys.getBattleHeroListKey(player[:playerId])
					heroIdListKey = Const::Rediskeys.getHeroListKey(player[:playerId])
					commonDao.update({battleHeroIdListKey => battleHeroIdList, heroIdListKey => heroIdList })
					{:retcode => Const::ErrorCode::Ok}
				else
					{:retcode => Const::ErrorCode::Fail}
				end
			else
				{:retcode => Const::ErrorCode::Fail}
			end
		end
		#英雄传承
		#@param[Integer,Integer Hash]
		#@return [Hash]
		def self.transHero(heroId,freeHeroId,player)
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
						battleHero[:exp] = battleHero[:exp] + freeHero[:exp]
						#TODO 处理battle hero升级
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
		def self.arrangeBattleHero(firstHeroId, secondHeroId, playerId)
			playerDao = PlayerDao.new
			heroDao = HeroDao.new
			commonDao = CommonDao.new
			metaDao = MetaDao.instance
			#取玩家信息
			player = playerDao.getPlayer(playerId)
			#player level的配表数据
			playerLevelMeta = metaDao.getPlayerLevelMetaData(player[:level])
			#上阵的英雄列表
			battleHeroIdList = heroDao.getBattleHeroIdList(player[:playerId])
			if battleHeroIdList.include?(firstHeroId) && battleHeroIdList.include?(secondHeroId)
				firstIndex = battleHeroIdList.index(firstHeroId)
				secondIndex = battleHeroIdList.index(secondHeroId)
				battleHeroIdList[secondIndex] = firstHeroId
				battleHeroIdList[firstIndex] = secondHeroId
				battleHeroIdListKey = Const::Rediskeys.getBattleHeroListKey(player[:playerId])
				commonDao.update({battleHeroIdListKey => battleHeroIdList})
				{:retcode => Const::ErrorCode::Ok}
			else
				{:retcode => Const::ErrorCode::Fail}
			end
		end
	end # class
end # model definition
