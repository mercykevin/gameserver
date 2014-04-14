module Model
	#任务系统
	#
	# 1：显示列表 {iid:status} , {iid:status}
	# 2：领取任务的时候，根据id领取任务，根据类型修改显示列表{有已完成就拿一个没有的话就根据开启任务获取一个iid}
	# 3：触发任务的时候，根据类型，维护一个已完成类型，如果显示列表有，删掉该任务 并且 修改显示列表中的状态
	class Task

		#任务列表
		#@param [Hash] player
		#@return [Hash] iid:status
		def self.getTaskList(playerId)
			taskList = {}
			metaDao = MetaDao.instance
			taskDao = TaskDao.new
			commonDao = CommonDao.new
			#所有本次要显示的idlist
			displayTaskList = taskDao.getDisplayList(playerId)
			#有任务可显示，直接显示
			if displayTaskList and displayTaskList.length > 0
				return {:retcode => Const::ErrorCode::Ok,:taskList => displayTaskList.to_json}
			else
				GameLogger.info("Model::Task.getTaskList method params playerId:#{playerId} , init task display list !")
				#有完成的任务，表示所有任务都完成了，无数据返回
				awardedList = taskDao.getAwardedList(playerId)
				if awardedList
					return {:retcode => Const::ErrorCode::Ok,:taskList => ""}
				end
				#玩家第一次，初始化显示列表，从量表取每种类型的第一个
				sortTaskList = metaDao.getFstTaskBySortWithStatus()
				taskDisplayedsKey = Const::Rediskeys::getTaskDisplayedsKey(playerId)
				commonDao.update(taskDisplayedsKey => sortTaskList)
				return {:retcode => Const::ErrorCode::Ok,:taskList => sortTaskList}
			end
		end

		#领取奖励
		#@param [Hash , Integer] 玩家信息，任务id
		#@return 
		def self.getTaskAward(player , iid)
			playerId = player[:playerId]
			metaDao = MetaDao.instance
			taskDao = TaskDao.new
			taskTemp = metaDao.getTaskMetaData(iid)
			#不存在
			if not taskTemp or taskTemp.empty?
				GameLogger.warn("Model::Task.getTaskAward playerId:#{playerId} , iid:#{iid}, the task is not exists ! ")
				return Const::ErrorCode.Fail
			end
			#已领取
			awardedList = taskDao.getAwardedList(playerId)
			if awardedList and awardedList.key?(iid.to_s)
				return Const::ErrorCode.TaskIsAlreadyGetAward
			end
		 	#处理奖励
		 	ret = Model::Reward::processAward(player , taskTemp.bReward)
		 	ret
		end


		#触发任务
		#@param [Hash,Integer,Hash] player , type:任务类型 ,param : 参数
		#@return 
		def self.checkTask(player , type ,param)
			if param or param.empty?
				return Const::ErrorCode.Fail
			end
			playerId = player[:playerId]
			#玩家的任务记录
			taskData = taskDao.getTaskMetaData(playerId , type)
			case type
			#战役 npcId
			when TaskTypeBattle
				if not param[:npcId]
					return Const::ErrorCode.Fail
				end

			#武将
			when TaskTypeHero
			#强化
			when TaskTypeRefine 
			#情谊
			when TaskTypeShip
			#竞技场
			when TaskTypeArena
			#培养
			when TaskTypeTrain 
			#通天塔相关
			when TaskTypeTower 
			#银矿
			when TaskTypeSilver 
			#夺宝
			when TaskTypeRob 
			#兵法进阶
			when TaskTypeBook 

			else
				GameLogger.error("Model::Task.checkTask method params type:#{type} , type is unhandle !")
				return Const::ErrorCode.Fail
			end
		end
	end
end
