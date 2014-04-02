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

			commonDao = CommonDao.new
			commonDao.update(Const::Rediskeys.getItemKey(item[:itemId],playerId),item.to_json)
		end


		#未装备列表
		def self.getItemUnusedList(playerId)
			itemDao = ItemDao.new
			itemDao.getItemUnusedList(playerId)
		end

		#已装备列表
		def self.getItemUsedList(playerId,sort)
			itemDao = ItemDao.new
			itemDao.getItemUsedList(playerId)
		end

		#宝物
		def self.getPropList()
			itemDao = ItemDao.new
			itemDao.getPropList(playerId)
		end

	end
end