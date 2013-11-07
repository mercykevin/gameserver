# -*- encoding : utf-8 -*-
require "json"
module Model
	class User
		def self.register(userName)
			playerNameKey = ::Model::Rediskeys.getPlayerNameKey(userName)
			if ::RedisClient.exists(userName)
				#用户已经存在
				{:retcode => Model::ErrorCode::Fail}
			else
				playerId = ::RedisClient.incr(::Model::Rediskeys.getPlayerIdAutoIncKey)
				player ={}
				player[:playerId] = playerId
				player[:playerName] = userName
				player[:level] = 0
				player[:money] = 0
				player[:siliver] = 0
				player[:books] = 0
				player[:gold] = 0
				player[:strength] = 0
				player[:command] = 0
				player[:exp] = 0
				player[:heroList] = []
				player[:itemList] = []
				::RedisClient.set(::Model::Rediskeys.getPlayerKey(playerId),player.to_json)
				::RedisClient.set(playerNameKey,playerId.to_s)
				{:retcode => Model::ErrorCode::Ok,:player => player}
			end
		end
		#获取用户信息接口
		def self.get(playerId)
			playerIdKey = ::Model::Rediskeys.getPlayerKey(playerId)
			player = ::RedisClient.get(playerIdKey)
			if player
				return JSON.parse(player)
			else
				return nil
			end
		end

		def self.set(player)
			RedisClient.set(::Model::Rediskeys.getPlayer[player["playerId"]],player.to_json)
		end

		def self.update(player)
			RedisClient.set(::Model::Rediskeys.getPlayer[player["playerId"]],player.to_json)
		end
		#根据用户名称获取用户信息
		def self.getByName(playerName)
			playerNameKey = ::Model::Rediskeys.getPlayerNameKey(playerName)
			playerId = ::RedisClient.get(playerNameKey)
			if playerId
				get(playerId)
			else
				nil
			end
		end
		#随机用户信息
		def self.randomName()
			nameList = ::RedisClient.get(::Model::Rediskeys.getRandomListKey())
			names = JSON.parse(nameList)
			if names.length > 0
				randNum = rand(names.length)
				randName = names[randNum]
				names.delete_at(randNum + 1)
				return randName
			end
			return ""			
		end

	end #class User
end # Sanguo
