require File.expand_path("../../test_helper",__FILE__)
require 'json'
class TaskTask < Minitest::Test

	# def test_getTaskList
	# 	player = Model::Player.register("andy","image")[:player]
	# 	ret = Model::Task::getDisplayTaskList(player[:playerId])
	# 	puts "获取任务列表: #{ret}"
	# end


	def test_checkTask
		player = Model::Player.register("andy","image")[:player]
		ret = Model::Task.checkTask(player , Const::TaskTypeBattle ,{:bsubid => 101006})
		puts "触发任务：#{ret}"
		list = Model::Task::getDisplayTaskList(player[:playerId])
		puts "触发任务后的任务列表：#{list}"

		puts "第二次触发此任务"

		ret = Model::Task.checkTask(player , Const::TaskTypeBattle ,{:bsubid => 101006})
		puts "触发任务：#{ret}"
		list = Model::Task::getDisplayTaskList(player[:playerId])
		puts "触发任务后的任务列表：#{list}"

		puts "---------------第二个任务"

		ret = Model::Task.checkTask(player , Const::TaskTypeBattle ,{:bsubid => 101107})
		puts "触发第二个任务：#{ret}"
		list = Model::Task::getDisplayTaskList(player[:playerId])
		puts "触发任务后的任务列表：#{list}"
		


		ret = Model::Task::getTaskAward(player , 800001)
		puts "领取任务：#{ret}"
		ret = Model::Task::getTaskAward(player , 800001)
		puts "第二次领取任务：#{ret}"


	end

	def test_getTaskAward 
		
	end

	# def test_processAward

	# 	String awards = "{\"siliver\":1111 , \"dimond\":5555 , \"item\":[[500001,1],[400001,2],[200001,3]] , \"hero\":[[300001,2],[400001,10]] ,\"soul\":[2000,5]}"
	# 	player = Model::Player.register("andy","image")[:player]
	# 	ret = Model::Reward.processAward(player ,awards , Const::FunctionConst::TaskGetAward )
	# 	puts "处理奖励的结果  #{ret}"
	# end




end
