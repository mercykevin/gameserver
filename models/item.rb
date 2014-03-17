module Model
	class Item
		def self.get(itemId,playerId)
			itemData = RedisClient.get(::Const::Rediskeys.getItemKey(itemId,playerId))
			if itemData and not itemData.empty?
				JSON.parse(itemData)
			end
		end

		def self.addItem(itemTempleteId,count,isOn,playerId)
			item = {}
			item[:itemId] = RedisClient.incr(::Const::Rediskeys.getItemIdAutoIncKey(playerId))
			item[:itemTempleteId] = itemTempleteId
			item[:count] = count
			player = ::Model::Player.get(playerId)
			player["itemList"] << itemId
			RedisClient.set(::Const::Rediskeys.getItemKey(item[:itemId],playerId),item.to_json)
			::Model::Player.update(player)
		end
	end
end