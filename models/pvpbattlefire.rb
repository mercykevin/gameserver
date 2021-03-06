module Model
	class PVPBattleFire < Model::BattleFire
		def initialize(attackPlayerId, defendPlayerId, battleType)
			battleDao = BattleDao.new
			playerDao = PlayerDao.new
			@attachHeroList = heroDao.getBattleHeroList(attackPlayerId)
			@defendHeroList = heroDao.getBattleHeroList(defendPlayerId)
			attack = battleDao.generatePlayerBattle(@attachHeroList)
			@attackPlayer = playerDao.getPlayer(attackPlayerId)
			defend = battleDao.generatePlayerBattle(@defendHeroList)
			@defendPlayer = playerDao.getPlayer(defendPlayerId)
			@battleType = battleType
			new(attack, @attackPlayer, defend, @defendPlayer)
		end
	end
end