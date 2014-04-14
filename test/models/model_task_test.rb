require File.expand_path("../../test_helper",__FILE__)
require 'json'
class TaskTask < Minitest::Test

	def test_getTaskList
		puts "第一次获取任务列表"
		ret = Model::Task::getTaskList({:playerId => 1})
		puts "第二次获取任务列表"
		ret = Model::Task::getTaskList({:playerId => 1})
		
		puts ret
	end


	def test_checkTask
		player = Model::Player.register("andy","image")[:player]
		ret = Model::Task::getTaskAward(player , 800001)
		ret = Model::Task::checkTask(player , Const::TaskTypeBattle , "{\"npcId\" : 600001}")
		puts "触发任务：#{ret}"
	end

	def test_getTaskAward
		player = Model::Player.register("andy","image")[:player]
		ret = Model::Task::getTaskAward(player , 800001)
		puts "领取任务：#{ret}"
	end



end
