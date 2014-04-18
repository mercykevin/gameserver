module Model
	class PVEBattleFire < Model::BattleFire
		# 创建pvebattle对象
		# @params[Integer,Integer]
		# @return PVEBattleFire's instance
		def initialize(playerId, battleId)
			heroDao = HeroDao.new
			playerDao = PlayerDao.new
			battleDao = BattleDao.new
			metaDao = MetaDao.instance
			@battleType = Const::BattleTypePVE
			@attachHeroList = heroDao.getBattleHeroIdList(playerId)
			player = playerDao.getPlayer(playerId)
			@metaBattle = metaDao.getSubBattleMetaData(battleId)
			@battleId = battleId
			#创建进攻方和防守方战斗单元
			attack = battleDao.generatePlayerBattle(@attachHeroList)
			defend = battleDao.generatePVENPC(battleId)
			super(attack, player, defend, "NPC")
		end
		#处理pve奖励
		def handleResult()
			super()
			needUpdate = {}
			metaDao = MetaDao.instance
			playerDao = PlayerDao.new
			metaBattle = @metaBattle
			@result[:money] = 0
			@result[:playerxp] = 0
			metaPlayer = metaDao.getPlayerLevelMetaData(@attackPlayer[:level])
			if @result[:win]
				#奖励金币和角色经验
				@result[:money] = metaBattle.bMoney.to_i
				@result[:playerxp] = metaPlayer.cBatlleEXP.to_i
				@result[:heroxp] = {}
				attackHeroList = @attachHeroList
				attackHeroList.each_with_index do |hero, index|
					if hero.class == Hash
						@result[:heroxp][index] = metaBattle.bGEXP.to_i
						#处理英雄升级
						heroDao.handleHeroLevelUp(hero, metaBattle.bGEXP.to_i)
						#写到report中
						@report[:attack][index][:newlevel] = hero[:level]
						heroKey = Const::Rediskeys.getHeroKey(hero[:heroId], @attackPlayer[:playerId])
						#英雄需要更新
						needUpdate[heroKey] = hero
					end
				end
			else
				@result[:money] = metaBattle.bFailureMoney.to_i
			end
			@attackPlayer[:siliver] = @attackPlayer[:siliver] + @result[:money]
			#处理用户升级
			playerDao.handlePlayerLevelUp(@attackPlayer, @result[:playerxp])
			playerKey = Const::Rediskeys.getPlayerKey(@attackPlayer[:playerId])
			#用户需要更新
			needUpdate[playerKey] = @attackPlayer
			#
			needUpdate
		end
	end
end