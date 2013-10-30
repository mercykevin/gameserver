module Mobile
	module Sanguo
		module Model
			class Rediskeys
				def self.getPlayerKey(playerId)
					"player:[#{playerId}]"
				end

				def self.getRandomListKey()
					"random_name_list"
				end

				def self.getCityKey(playerId)
					"city:[#{playerId}]"
				end

				def self.getBuildingKey(playerId,buildName)
					"city_building:[#{playerId}]:[#{buildName}]"
				end

				def self.getHeroKey(playerId,heroId)
					"hero:[#{{playerId}}]:[#{heroId}]"
				end

				def self.getItemKey(playerId,itemId)
					"item:[#{playerId}]:[#{itemId}]"
				end

				def self.getHeroIdAutoIncKey(playerId)
					"hero_id_inc:[#{playerId}]"
				end

				def self.getItemIdAutoIncKey(playerId)
					"item_id_inc:[#{playerId}]"
				end
			end
		end
	end
end