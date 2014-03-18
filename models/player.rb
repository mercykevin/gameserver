# -*- encoding : utf-8 -*-
require "json"
module Model
	class Player
		# register new player with name.
  		#
  		# @param [String] playerName 
  		# @return [Hash] player's information store with Hash or nil if player is not exist
		def self.register(playerName)
			playerDao = PlayerDao.new
			commonDao = CommonDao.new
			if playerDao.existByName?(playerName)
				#用户已经存在
				{:retcode => Const::ErrorCode::PlayerIsExistByName}
			else
				#用户id自增长
				playerId = playerDao.generatePlayerId
				player = {}
				player[:playerId] = playerId
				player[:playerName] = playerName
				player[:level] = 0
				player[:money] = 0
				player[:siliver] = 0
				player[:books] = 0
				player[:gold] = 0
				player[:strength] = 0
				player[:command] = 0
				player[:exp] = 0
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
			name
		end
	end #class Player
end # End Moudle
