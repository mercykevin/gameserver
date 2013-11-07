module Model
	class Item
		def self.get(itemId,playerId)
			itemData = RedisClient.get(::Model::Rediskeys.getItemKey(itemId,playerId))
			if itemData and not itemData.empty?
				JSON.parse(itemData)
			end
		end

		def self.addItem(itemTempleteId,count,isOn,playerId)
			item = {}
			item[:itemId] = RedisClient.incr(::Model::Rediskeys.getItemIdAutoIncKey(playerId))
			item[:itemTempleteId] = itemTempleteId
			item[:count] = count
			player = ::Model::User.get(playerId)
			player["itemList"] << itemId
			RedisClient.set(::Model::Rediskeys.getItemKey(item[:itemId],playerId),item.to_json)
			::Model::User.update(player)
		end
	end
end