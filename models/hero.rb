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
			hero[:templeteHeroId] = templeteHero.GeneralID
			hero[:playerId] = player[:playerId]
			hero[:attack] = templeteHero.gInitialATK.to_f
			hero[:defend] = templeteHero.gInitialDEF.to_f
			hero[:intelegence] = 0
			hero[:blood] = templeteHero.gInitialHP.to_f 
			hero[:exp] = 0
			hero[:star] = templeteHero.gStart.to_i
			hero[:level] = 1
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
	end # class
end # model definition
