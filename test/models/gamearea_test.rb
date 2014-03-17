require File.expand_path("../../test_helper" ,__FILE__)

class GameAreaTest < Test::Unit::TestCase
	def test_getGameAreas
		game_area = 
		[
			{:areaId =>1,:areaName => "三国鼎立",:areaHost => "http://127.0.0.1",:areaPort => 4567,:areaStatus =>"new"},
			{:areaId =>2,:areaName => "初出茅庐",:areaHost => "http://127.0.0.1",:areaPort => 4567,:areaStatus =>"new"},
			{:areaId =>3,:areaName => "火烧赤壁",:areaHost => "http://127.0.0.1",:areaPort => 4567,:areaStatus =>"hot"}
		]
		RedisClient.set(Const::Rediskeys.getGameAreasKey,game_area.to_json)
		areaList = Model::GameArea.getGameAreas
		i = 0
		areaList.each do |area|
			if i == 0 
				assert_equal("三国鼎立",area["areaName"])
			elsif i == 1
				assert_equal("初出茅庐",area["areaName"])
			elsif i == 2
				assert_equal("火烧赤壁",area["areaName"])
			end
			i = i + 1
		end
	end
end