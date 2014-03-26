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
				player[:siliver] = 10000
				player[:diamond] = 0
				player[:strength] = 0
				player[:command] = 30
				player[:books] = 15
				player[:exp] = 0
				player[:freeheromax] = 50
				player[:vip] = 0
				player[:headimg] = headImg
				#更新player信息到redis中
				playerDao.create(player)
				{:retcode => Const::ErrorCode::Ok,:player => player}
			end
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
	end #class Player
end # End Moudle
