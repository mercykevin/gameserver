require File.expand_path("../../test_helper",__FILE__)
require 'json'
class TaskTask < Minitest::Test

	# def test_getTaskList
	# 	player = Model::Player.register("andy","image")[:player]
	# 	ret = Model::Task::getDisplayTaskList(player[:playerId])
	# 	puts "获取任务列表: #{ret}"
	# end
	def test_test
		player = Model::Player.register("andy","image")[:player]
		playerId = player[:playerId]
		Model::Task.addData4TaskTest(player)
		list = Model::Task::getDisplayTaskList(player[:playerId])
		puts "-----test------触发任务后的任务列表：#{list}"
		ret = Model::Task::getTaskAward(player , 802001)
		puts "领取任务返回：#{ret}"
	end


	def test_checkTask
		player = Model::Player.register("andy","image")[:player]
		playerId = player[:playerId]
			taskDao  = TaskDao.new
		# ret = Model::Task.checkTask(player , Const::TaskTypeBattle ,{:bsubid => 101006})
		# puts "触发任务：#{ret}"
		# list = Model::Task::getDisplayTaskList(player[:playerId])
		# puts "触发任务后的任务列表：#{list}"

		# puts "第二次触发此任务"

		# ret = Model::Task.checkTask(player , Const::TaskTypeBattle ,{:bsubid => 101006})
		# puts "触发任务：#{ret}"
		# list = Model::Task::getDisplayTaskList(player[:playerId])
		# puts "触发任务后的任务列表：#{list}"

		# puts "---------------第二个任务"
	
		# complatedList = taskDao.getComplatedList(player[:playerId])
		# puts "触发第二个任务前的完成列表：#{complatedList}"
		# ret = Model::Task.checkTask(player , Const::TaskTypeBattle ,{:bsubid => 101107})
		# puts "触发第二个任务：#{ret}"

		# list = Model::Task::getDisplayTaskList(player[:playerId])
		# puts "触发任务后的任务列表：#{list}"
		# complatedList = taskDao.getComplatedList(player[:playerId])		
		# puts "触发第二个任务后的完成列表：#{complatedList}"
		# awardedList = taskDao.getAwardedList(player[:playerId])
		# puts "触发第二个任务后的已领取列表：#{awardedList}"


		# puts "----------------领取任务"
		# ret = Model::Task::getTaskAward(player , 800001)
		# puts "领取任务返回：#{ret}"
		# ret = Model::Task::getTaskAward(player , 800001)
		# puts "第二次领取任务：#{ret}"
		# puts "----领取任务后的三个列表数据----"
		# list = Model::Task::getDisplayTaskList(player[:playerId])
		# puts "触发任务后的任务列表：#{list}"
		# complatedList = taskDao.getComplatedList(player[:playerId])		
		# puts "领取任务任务后的完成列表：#{complatedList}"
		# awardedList = taskDao.getAwardedList(player[:playerId])
		# puts "触发第二个任务后的已领取列表：#{awardedList}"


		puts "----------------添加2星装备，测试装备类的任务"

		puts "添加武器"
		count = 2
		iid = 410104
		Model::Item.addItem(player,iid,count)

		# puts "添加防具"
		# count = 2
		# iid = 420804
		# Model::Item.addItem(player,iid,count)

		# puts "添加坐骑"	
		# count = 2
		# iid = 430101
		# Model::Item.addItem(player,iid,count)
	
		itemList = Model::Item.getEquipeAllList(playerId)  
		puts "装备列表装备列表 #{itemList.size} #{itemList}"
		list = Model::Task::getDisplayTaskList(player[:playerId])
		puts "触发任务后的任务列表：#{list}"
		complatedList = taskDao.getComplatedList(player[:playerId])		
		puts "触发任务后的完成列表：#{complatedList}"
		awardedList = taskDao.getAwardedList(player[:playerId])
		puts "触发任务后的领取列表：#{awardedList}"
		
		ret = Model::Task::getTaskAward(player , 802001)
		puts "领取任务返回：#{ret}"
	end

	def test_getTaskAward 
		
		# puts "----------------添加道具，测试道具类的任务"
		# iid = 400001
		# count = 5
		# Model::Item.addItem(player,iid,count)
		
		# #兵法
		# iid = 500001
		# count = 4
		# Model::Item.addItem(player,iid,count)

		# #物品
		# iid = 200000
		# count = 3
		# Model::Item.addItem(player,iid,count)
	end

	# def test_processAward

	# 	String awards = "{\"siliver\":1111 , \"dimond\":5555 , \"item\":[[500001,1],[400001,2],[200001,3]] , \"hero\":[[300001,2],[400001,10]] ,\"soul\":[2000,5]}"
	# 	player = Model::Player.register("andy","image")[:player]
	# 	ret = Model::Reward.processAward(player ,awards , Const::FunctionConst::TaskGetAward )
	# 	puts "处理奖励的结果  #{ret}"
	# end




end
