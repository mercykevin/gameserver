module Model
	#任务系统
	#
	# 1：显示列表 {iid:status} , {iid:status}
	# 2：领取任务的时候，从displaylist移除，添加下一个（complatelist有就取出来，没有就根据表添加）
	# 3：触发任务的时候，修改displaylist
	class Task

		#任务列表    排序TODO
		#@param [Hash] player
		#@return [Hash] iid:status
		def self.getDisplayTaskList(playerId)
			taskList = {}
			metaDao = MetaDao.instance
			taskDao = TaskDao.new
			commonDao = CommonDao.new
			#所有本次要显示的idlist
			displayTaskList = taskDao.getDisplayList(playerId)
			return {:retcode => Const::ErrorCode::Ok,:taskList => displayTaskList.to_json}
		end

		#任务列表
		#@param [Hash] player
		#@return [Hash] iid:status
		def self.initDisplayTaskList(playerId)
			metaDao = MetaDao.instance
			taskDao = TaskDao.new
			commonDao = CommonDao.new
			#没有可显示的并且 有已领取的任务，表示所有任务都完成了，无数据返回
			awardedList = taskDao.getAwardedList(playerId)
			if awardedList
				GameLogger.info("Model::Task.initDisplayTaskList method  playerId:#{playerId} , need not init task list !")
				return  
			end
			#玩家第一次，初始化显示列表，从量表取每种类型的第一个
			sortFstTaskList = metaDao.getFstTaskBySortWithStatus()
			taskDisplayedsKey = Const::Rediskeys::getTaskDisplayedsKey(playerId)
			commonDao.update(taskDisplayedsKey => sortFstTaskList)
			GameLogger.info("Model::Task.initDisplayTaskList method  playerId:#{playerId} , init task display list ok !")
		end


		#领取奖励
		#@param [Hash , Integer] 玩家信息，任务id
		#@return 
		def self.getTaskAward(player , iid)
			playerId = player[:playerId]
			metaDao = MetaDao.instance
			taskDao = TaskDao.new
			commonDao = CommonDao.new
			taskTemp = metaDao.getTaskMetaData(iid)
			#不存在
			if not taskTemp or taskTemp.empty?
				GameLogger.warn("Model::Task.getTaskAward playerId:#{playerId} , iid:#{iid}, the task is not exists ! ")
				return Const::ErrorCode::Fail
			end
			#已领取
			awardedList = taskDao.getAwardedList(playerId)
			if awardedList and awardedList.include?(iid.to_s)
				return Const::ErrorCode::TaskIsAlreadyGetAward
			end
			#是否已完成
			displayTaskList = taskDao.getDisplayList(playerId)
			if  displayTaskList and displayTaskList[iid.to_s] != Const::StatusEnable
				return Const::ErrorCode::TaskIsNotBeComplated
			end
		 	#处理奖励
		 	ret = Model::Reward::processAward(player , taskTemp.bReward , Const::FunctionConst::TaskGetAward)
		 	#本任务从显示列表中移除
		 	displayTaskList.delete(iid.to_s)
		 	if  awardedList == nil
		 		awardedList = []
		 	end
		 	awardedList << iid.to_i
		 	#有下一个任务
		 	if taskTemp.qFollwoUP  
		 		nextTaskTemp = metaDao.getTaskMetaData(taskTemp.qFollwoUP)
		 		if nextTaskTemp and not nextTaskTemp.empty?
		 			#已完成
		 			complatedList = taskDao.getComplatedList(playerId)
				 	if complatedList and complatedList.include?(nextTaskTemp.questID)
				 		#添加到显示列表
				 		displayTaskList[nextTaskTemp.questID] = Const::StatusEnable
				 		#从已完成列表中移除
				 		complatedList.delete(nextTaskTemp.questID)
				 		taskComplatedsKey = Const::Rediskeys::getTaskComplatedsKey(playerId)
				 		ret[taskComplatedsKey] = complatedList
				 	else
				 		#未完成添加到显示列表中
			 			displayTaskList[nextTaskTemp.questID] = Const::StatusDisable
				 	end
		 		end
		 	end
		 	#保存奖励，修改任务显示列表
		 	taskDisplayedsKey = Const::Rediskeys::getTaskDisplayedsKey(playerId)
		 	taskAwardedKey = Const::Rediskeys::getTaskAwardedKey(playerId)
		 	ret[taskDisplayedsKey] = displayTaskList
		 	ret[taskAwardedKey] = awardedList
		 	puts "ret - - - -- #{ret}"
		 	commonDao.update(ret)
		 	ret
		end

		#计算出触发的任务iid
		#@param [Hash,Integer,Hash] player , type:任务类型 ,param : 参数 如：{:bsubid => 101006}
		#@return [Hash] taskTemp 
		def self.calcIidForCheckStatus(player , type ,param)
			metaDao = MetaDao.instance
			sortTaskList = metaDao.getTaskListBySort(type)
			if  not sortTaskList or sortTaskList.empty?
				return nil 
			end

			sortTaskList.each do |taskTemp|
				#条件
				needParam = JSON.parse(taskTemp.bComplete, {:symbolize_names => true})
				GameLogger.info("Model::Task.calcIidForCheckStatus  condtion:#{needParam} , param:#{param} !")
				case taskTemp.qType
				#战役 npcId
				when Const::TaskTypeBattle
					if  param[:bsubid].to_i == needParam[:bsubid].to_i
						return taskTemp
					end
				#武将数量
				when Const::TaskTypeHero
					needStar = needParam[:star]
					needLevel = needParam[:num]
					#TODO
					if false
						return taskTemp
					end
				#装备数量
				when Const::TaskTypeEquip
				#并发数量
				when Const::TaskTypeBook
				#强化
				when Const::TaskTypeRefine 
				#情谊
				when Const::TaskTypeShip
				#竞技场
				when Const::TaskTypeArena
				#竞技场连胜
				when Const::TaskTypeArenaWin
				#培养
				when Const::TaskTypeTrain 
				#通天塔相关
				when Const::TaskTypeTower 
				#银矿
				when Const::TaskTypeSilver 
				#夺宝
				when Const::TaskTypeRob 
				#兵法进阶
				when Const::TaskTypeBookAdvance 

				else
					GameLogger.error("Model::Task.checkTask method params type:#{type} , type is unhandle !")
					nil
				end
			end
			nil
		end

		#触发任务
		#@param [Hash,Integer,Hash] player , type:任务类型 ,param : 参数 如：{:npc => 600010}
		#@return [Hash] taskTemp 
		def self.checkTask(player , type ,param)
			taskDao = TaskDao.new
			commonDao = CommonDao.new
			if not param or param.empty?
				GameLogger.info("Model::Task.checkTask type:'#{type}' param is empty !")
				return 
			end
			playerId = player[:playerId]
			tempTask = calcIidForCheckStatus(player , type , param)
			#任务不存在
			if not tempTask
				GameLogger.info("Model::Task.checkTask type:'#{type}' param:'#{param}' , tempTask is not exists !")
				return 
			end
			taskIid = tempTask.questID
			#已领取
			awardedList = taskDao.getAwardedList(playerId)
			if awardedList and awardedList.key?(taskIid)
				GameLogger.info("Model::Task.checkTask taskIid:#{taskIid} is already in awardedList !")
				return 
			end
			#已完成
			displayTaskList = taskDao.getDisplayList(playerId)
			if displayTaskList and displayTaskList[taskIid] == Const::StatusEnable
				GameLogger.info("Model::Task.checkTask taskIid:#{taskIid} is already in complatedList !")
				return 
			end
			#显示列表已存在，修改状态
			if displayTaskList and displayTaskList.has_key?(taskIid)
				displayTaskList[taskIid.to_s] = Const::StatusEnable
				taskDisplayedsKey = Const::Rediskeys::getTaskDisplayedsKey(playerId)
			 	commonDao.update({taskDisplayedsKey => displayTaskList})
			 	GameLogger.info("Model::Task.checkTask taskIid:#{taskIid} updated into displayTaskList !")
			else
				#添加到已完成列表中
				complatedList = taskDao.getComplatedList(playerId)
				if complatedList == nil
					complatedList = []
				end
				complatedList << taskIid.to_i
				taskComplatedsKey = Const::Rediskeys::getTaskComplatedsKey(playerId)
			 	commonDao.update({taskComplatedsKey => complatedList})
			 	GameLogger.info("Model::Task.checkTask taskIid:#{taskIid} saved into complatedList !")
			end
		end
	end
end
