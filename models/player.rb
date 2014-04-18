# -*- encoding : utf-8 -*-
require "json"
module Model
	class Player
		# register new player with name.
  		#
  		# @param [String,String,String] player name ,head img ,meta hero id
  		# @return [Hash] player's information store with Hash or nil if player is not exist
		def self.register(playerName,headImg)
			playerDao = PlayerDao.new
			commonDao = CommonDao.new
			metaDao = MetaDao.instance
			
			GameLogger.debug("Model::Player.register playerName:#{playerName}")
			if playerDao.existByName?(playerName)
				#用户已经存在
				player = playerDao.getPlayerByName(playerName)
				{:retcode => Const::ErrorCode::Ok,:player => player}
			else
				#用户id自增长
				playerId = playerDao.generatePlayerId
				player = {}
				player[:playerId] = playerId
				player[:playerName] = playerName
				player[:level] = 1
				player[:siliver] = metaDao.getFlagValue("player_init_siliver").to_i
				player[:diamond] = metaDao.getFlagValue("player_init_diamond").to_i
				player[:strength] = 0
				player[:command] = 30
				player[:books] = 15
				player[:exp] = 0
				player[:freeheromax] = 50
				player[:vip] = 0
				player[:headimg] = headImg
				#背包格子数量
				player[:backpackCount] = initBackpackCount
				#更新player信息到redis中
				playerDao.create(player)
				#初始化任务显示列表
				Model::Task.initDisplayTaskList(player[:playerId])
				{:retcode => Const::ErrorCode::Ok,:player => player}
			end
		end
		#返回数组
		#[武器，防具，坐骑，兵法，宝物]
		#索引就是对应常量 -1 
		#@return [Array]
		def self.initBackpackCount()
			defaultCount = MetaDao.instance.getFlagValue("pack_cell_init_count").to_i
			backpackCount = []
			for i in 1..5 
				backpackCount.push(defaultCount)
			end
			backpackCount			
		end

		# get player info by player id
  		#
  		# @param [String] playerId 
  		# @return [Hash] player's information
		#获取用户信息接口
		def self.get(playerId)
			playerDao = PlayerDao.new
			playerDao.getPlayer(playerId)
		end

		# get player info by player name
  		#
  		# @param [String] playerName 
  		# @return [Hash] player's information
		#获取用户信息接口
		def self.getByName(playerName)
			playerDao = PlayerDao.new
			playerDao.getPlayerByName(playerName)
		end

		# random player name with design configuration
		#
		# @return [String] player name
		def self.randomName(gender)
			playerDao = PlayerDao.new
			name = nil 
			begin
				name = MetaDao.instance.generatePlayerName(gender)
			end while playerDao.existByName?(name)
			GameLogger.debug("Model::Player.randomName:the rand name = #{name}") 
			name
		end
		#根据session获取用户信息
		#@param [String] session id
		#@return [Hash]
		def self.getBySession(sessionId)
			sessionDao = SessionDao.new
			playerDao = PlayerDao.new
			playerId = sessionDao.getPlayerIdBySession(sessionId)
			if playerId
				playerDao.getPlayer(playerId)
			else
				nil
			end
		end

		def self.setOnline(sessionId,playerId)
			sessionDao = SessionDao.new
			sessionDao.setPlayerIdBySession(sessionId,playerId)
		end

		#银币消耗/获得 ，消耗传负数 ，没有保存
		#@param [Hash , Integer , Integer] palyer，siliver(+/-)，function(如：强化功能，Const::FunctionConst::EquipStrengthen)
		#@return [Hash] player
		def self.addSiliver(player , siliver , function)
			player[:siliver] = player[:siliver].to_i + siliver.to_i
			GameLogger.info("Model::Player.addSiliver : playerId:#{player[:playerId]} siliver:#{siliver} function:#{function} ! " ) 
			player
		end
		#钻石消耗/获得 ，消耗传负数 ，没有保存 
		#@param [Hash , Integer , Integer] palyer，siliver(+/-)，function(如：强化功能，Const::FunctionConst::EquipStrengthen)
		#@return [Hash] player
		def self.addDiamond(player , diamond , function)
			player[:diamond] = player[:diamond].to_i + diamond.to_i
			GameLogger.info("Model::Player.addDiamond : playerId:#{player[:playerId]} diamond:#{diamond} function:#{function} ! " ) 
			player
		end


	end #class Player
end # End Moudle
