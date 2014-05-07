#set sinatra run environment
ENV["RACK_ENV"] = "test"
#加载redis 和active record,扫描module和controller
require File.expand_path('../boot', __FILE__)
#add meta data
game_area = 
[
	{:areaId =>1,:areaName => "三国鼎立",:areaHost => "http://127.0.0.1",:areaPort => 4567,:areaStatus =>"new"},
	{:areaId =>2,:areaName => "初出茅庐",:areaHost => "http://127.0.0.1",:areaPort => 4567,:areaStatus =>"new"},
	{:areaId =>3,:areaName => "火烧赤壁",:areaHost => "http://127.0.0.1",:areaPort => 4567,:areaStatus =>"hot"}
]
RedisClient.set(Const::Rediskeys.getGameAreasKey,game_area.to_json)
#hero meta data
heroTempleteData =
[
	{:templeteId =>1,:name => "张飞",:attack => 10,:defend => 20,:blood => 10},
	{:templeteId =>2,:name => "关羽",:attack => 10,:defend => 20,:blood => 10},
	{:templeteId =>3,:name => "刘备",:attack => 10,:defend => 20,:blood => 10}
]






