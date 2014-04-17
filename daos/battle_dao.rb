class BattleDao
	# 创建战役npc的列表
	# @param[Integer]
	# @return [Array]
	def createBatteNPC(battleId)

	end
	#取战役信息
	# @param[Integer,Integer]
	# @return [Hash]
	def getSubBattleInfoMap(battleId, playerId)
		key = Const::Rediskeys.getBattleListKey(battleId, playerId)
		battleInfo = RedisClient.get(key)
		if battleInfo
			JSON.parse(battleInfo, {:symbolize_names => true})
		else
			{}
		end
	end
  	# 添加战役信息到列表中
  	# @param [Integer]
  	# @return [Hash]
  	def updateSubBattle(battleId,stars,isWin)
  		metaDao = MetaDao.instance
  	end
  	# 取大战役的
  	# @param [Integer]
  	# @return [Array]		
  	def getBattleIdList(playerId)
  		key = Const::Rediskeys.getBattleIdListKey(playerId)
  		battleIdList = RedisClient.get(key)
  		if battleIdList
  			JSON.parse(battleIdList, {:symbolize_names => true})
  		else
  			[]
  		end
  	end
  	# 添加战役信息
  	# @param [Integer]
  	# @return [Hash]
  	def addBattleIdToList(subBattleId,playerId)
  		battleIdList = getBattleIdList(playerId)
		if not battleIdList.include?(subBattleId)
			battleIdList << subBattleId
		end
		key = Const::Rediskeys.getBattleIdListKey(playerId)
		{key=>battleIdList}
  	end

    # 创建英雄列表从npc配表数据
    # @param [String] subBattleId
    # @return [Hash]
    def generatePVENPC(subBattleId)
      pvenpc = Hash.new
      metaDao = MetaDao.instance
      battleMetaData = metaDao.getSubBattleMetaData(subBattleId)
      npcList = JSON.parse(battleMetaData.bNPCID)
      npcList.each_with_index do |npcId, index|
        npcmetaData = metaDao.getNPC(npcId)
        npc = {:id=>index, :attack=>npcmetaData.nATK.to_i, :defend=>npcmetaData.nDEF.to_i, 
                :intelegence=>npcmetaData.nINT.to_i, :blood=>npcmetaData.nHP.to_i, 
                :level=>1,:name=>npcmetaData.nName, :headpic=>npcmetaData.nIconsID, :isAction=>false, 
                :index=>index }
        pvenpc[index] = npc      
      end
      pvenpc
    end

    # 创建玩家的战斗列表
    # @param [Integer] playerId
    # @return [Array]
    def generatePlayerBattle(playerId)
      heroBattleHash = Hash.new
      metaDao = MetaDao.instance
      heroDao = HeroDao.new
      heroList = heroDao.getBattleHeroList(playerId)
      heroList.each_with_index do |hero, index|
        if Hash == hero.class
          #存在英雄信息
          heroMetaData = metaDao.getHeroMetaData(hero[:templeteHeroId])
          heroBattle = {:id=>hero[:heroId], :attack=>hero[:attack], :defend=>hero[:defend],
            :intelegence=>hero[:intelegence], :blood=>hero[:blood], :level=>hero[:level], 
            :name=>heroMetaData.gName, :isAction=>false, :index=>index}
          heroBattleHash[index] = heroBattle  
        end
      end
      heroBattleHash
    end
end