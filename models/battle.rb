module Model
	class Battle
		# 取战役子列表
		# @param [Integer]
		# @return [Array]
		def self.getBattleSubList(battleName, playerId)
			metaDao = MetaDao.instance
			battleDao = BattleDao.new
			subBattleList = metaDao.getSubBattleListByName(battleName, playerId)
			subBattleHash = battleDao.getSubBattleInfoHash(battleName, playerId)
			subBattleList.each do |temp|
				subBattle = subBattleHash[temp.battleID]
			end
		end
		# 推图
		# @param[String,Integer]
		# @return[Hash]
		def self.pve(battleId,playerId)

		end
		#获取战役大类列表
		# @param nothing
		# @return [Array]
		def self.getBattleList
			metaDao = MetaDao.instance
			metaDao.getBattleList
		end
	end # end class
end # end model