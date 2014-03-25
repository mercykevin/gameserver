module Model
	class Hero
		#招募英雄
		#@param [String,Hash,String]
		#@return [Hash]
		def self.recuritHero(templeteHeroId,player,recuritetype)
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
			case recuritetype
			when "normal"
				#普通招募验证有没有到冷却时间
				metaData = metaDao.getRecuriteMetaData("普通")
				if recruiteinfo.key?(:recuritetime1)
					lefttime = lefttime - recruiteinfo[:recuritetime1]
				end
			when "advanced"
				#高级招募
				metaData = metaDao.getRecuriteMetaData("高级")
				if recruiteinfo.key?(:recuritetime2) 
					lefttime = lefttime - recruiteinfo[:recuritetime2]
				end
			else
				metaData = metaDao.getRecuriteMetaData("英雄令")
				if recruiteinfo.key?(:recuritetime3)
					lefttime = lefttime - recruiteinfo[:recuritetime3]
				end
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
			{:retcode => Const::ErrorCode::Ok,:hero => hero}
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
	end # class
end # model definition
