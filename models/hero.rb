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
			case recuritetype
			when "normal"
				#普通招募验证有没有到冷却时间
				metaData = metaDao.getRecuriteMetaData("普通")
				if player.key?(:recuriteherocd) && (Time.now.to_i - player[:recuriteherocd]) < metaData.rFreeCooling.to_i
					return {:retcode => Const::ErrorCode::HeroRecuritCDError}
				end
			when "advanced"
				#高级招募
				metaData = metaDao.getRecuriteMetaData("高级")
				if player.key?(:recuriteheroadvancedcd) and (Time.now.to_i - player[:recuriteheroadvancedcd]) < metaData.rFreeCooling.to_i
					return {:retcode => Const::ErrorCode::HeroRecuritCDError}
				end 
			else
				metaData = metaDao.getRecuriteMetaData("英雄令")
			end
			#创建英雄
			hero = createHero(templeteHero, player, heroIdList)
			#更新相关信息到redis中
			case recuritetype
			when "normal"
				player[:recuriteherocd] = Time.new.to_i
				#TODO 扣钱
			when "advanced"
				player[:recuriteheroadvancedcd] = Time.new.to_i
			else
			end	
			heroIdListKey = Const::Rediskeys.getHeroListKey(player[:playerId])
			herokey = Const::Rediskeys.getHeroKey(hero[:heroId],player[:playerId])
			playerkey = Const::Rediskeys.getPlayerKey(player[:playerId])
			commonDao.update({herokey => hero, heroIdListKey => heroIdList, playerkey => player})
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
						battleHeroKey = Const::Rediskeys.getHeroKey(battleHero[:heroId],playerId)
						freeHeroKey = Const::Rediskeys.getHeroKey(freeHero[:heroId],playerId)
						heroIdListKey = Const::Rediskeys.getHeroListKey(player[:playerId])
						commonDao.update({battleHeroKey => battleHero, freeHeroKey => nil,heroIdListKey => heroIdList})
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
	end # class
end # model definition
