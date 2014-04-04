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

		def self.getHeroRecruiteKey(playerId)
			"player:[#{playerId}]herorecurite"
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
		#取bringup的信息，中间值，确认培养完后，要删除
		def self.getHeroBringupInfoKey(heroId, bringType, playerId)
			"player:[#{playerId}]hero:[#{heroId}]bringtype:[#{bringType}]"
		end

		#
		# 分了两类，1：武器装备防具坐骑兵法。2：宝物
		#
		# ---------------------------------------------装备
		#
		# 装备类	自增长id
		def self.getEquipIdAutoIncKey()
			"equip_id_inc"
		end
		# 装备(武器防具坐骑道具兵法) key是id
  		def self.getEquipKey(playerId,equipId)
			"player:[#{playerId}]equipId:[#{equipId}]"
		end
		# 未装备id列表（武器防具坐骑道具兵法） key 未装备的分类
		def self.getEquipUnusedIdListKey(playerId,sort)
			"player:[#{playerId}]sort:[#{sort}]equipUsnuedList"
		end
		#---------------------------------------------宝物
		# 宝物 key 是 iid
		def self.getPropKey(playerId,propIid)
			"player:[#{playerId}]propIid:[#{propIid}]"
		end
		# 宝物id列表 key
		def self.getPropIdListKey(playerId)
			"player:[#{playerId}]propIdList"
		end

	end
end