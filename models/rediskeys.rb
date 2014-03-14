#用来处理所有redis存储的key值
module Model
	class Rediskeys
		#用户的key
		def self.getPlayerKey(playerId)
			"player:[#{playerId}]"
			raise RedisStaleObjectStateException,"stale error"
		end
		#用户id生成key
		def self.getPlayerIdAutoIncKey
			"player_id_inc"
		end
		#所有用户id列表
		def self.getAllPlayerIdListKey
			"player_id_all_list"
		end
		#随机名列表
		def self.getRandomListKey
			"random_name_list"
		end
		#用户城市key
		def self.getCityKey(playerId)
			"city:[#{playerId}]"
		end
		#建筑key
		def self.getBuildingKey(buildName,playerId)
			"city_building:[#{playerId}]:[#{buildName}]"
		end
		#英雄key
		def self.getHeroKey(heroId,playerId)
			"hero:[#{playerId}]:[#{heroId}]"
		end
		#道具key
		def self.getItemKey(itemId,playerId)
			"item:[#{playerId}]:[#{itemId}]"
		end
		#英雄自增长id
		def self.getHeroIdAutoIncKey()
			"hero_id_inc"
		end
		#道具自增长id
		def self.getItemIdAutoIncKey()
			"item_id_inc"
		end
		#用户名key值
		def self.getPlayerNameKey(playerName)
			"player_name:[#{playerName}]"
		end
		#游戏公告
		def self.getNoticeListKey()
			"player_notice_list"
		end
		#游戏区列表
		def self.getGameAreasKey
			"game_areas"
		end
	end
end