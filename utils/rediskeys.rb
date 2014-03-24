#用来处理所有redis存储的key值
module Const
	class Rediskeys
		#用户的key
		def self.getPlayerKey(playerId)
			"player:[#{playerId}]"
		end
		#用户id生成key
		def self.getPlayerIdAutoIncKey
			"player_id_inc"
		end
		#所有用户id列表
		def self.getAllPlayerIdListKey
			"player_id_all_list"
		end
		#用户名key值
		def self.getPlayerNameKey(playerName)
			"player_name:[#{playerName}]"
		end
		#用户城市key
		def self.getCityKey(playerId)
			"player:[#{playerId}]city"
		end
		#建筑key
		def self.getBuildingKey(buildName,playerId)
			"player:[#{playerId}]city_building:[#{buildName}]"
		end
		#英雄key
		def self.getHeroKey(heroId,playerId)
			"player:[#{playerId}]hero:[#{heroId}]"
		end
		#所有英雄的id列表
		def self.getHeroListKey(playerId)
			"player:[#{playerId}]herolist"
		end
		#获取战斗英雄的列表
		def self.getBattleHeroListKey(playerId)
			"player:[#{playerId}]battleherolist"
		end
		#英雄自增长id
		def self.getHeroIdAutoIncKey()
			"hero_id_inc"
		end
		#道具key
		def self.getItemKey(itemId,playerId)
			"player:[#{playerId}]item[#{itemId}]"
		end
		#道具自增长id
		def self.getItemIdAutoIncKey()
			"item_id_inc"
		end
		#游戏公告
		def self.getNoticeListKey()
			"player_notice_list"
		end
		#游戏区列表
		def self.getGameAreasKey
			"game_areas"
		end
		#获取session key
		def self.getSessionKey(sessionId)
			"gamesession:[#{sessionId}]"
		end
	end
end