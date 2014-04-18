require File.expand_path("../../test_helper",__FILE__)
require 'json'
class RandomTest < Minitest::Test

 	def test_processAward
		player = Model::Player.register("andy","image")[:player]

		awards = "{\"siliver\":100,\"dimond\":500,\"item\":{\"410502\":1,\"420403\":2,\"430105\":3,\"411008\":4} , \"hero\":{\"300001\":2,\"400001\":10} ,\"soul\":{\"2000\":5}}"
		puts "奖励字符串：#{awards}"
		ret = Model::Reward.processAward(player,awards,"test")
	end


end