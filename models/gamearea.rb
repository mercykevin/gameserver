require 'json'
module Model
	class GameArea
		#[{:areaId =>1,:areaName => "三国鼎立",:areaHost => "http://127.0.0.1",:areaPort => 4567,:areaStatus = >"new|hot"}]
		def self.getGameAreas
			value = RedisClient.get(Model::Rediskeys.getGameAreasKey)
			JSON.parse(value)
		end
	end
end