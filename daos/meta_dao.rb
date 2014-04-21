require "json"
require 'singleton'
require 'csv'
class MetaDao
	include Singleton
	# read meta data from csv file
	# @param [String] csvfile ,the path of csv file
	# @return nothing
	def initMetaDataFromCSV(csvfile)
		if not File.exist?(csvfile)
			raise StandardError "file not exist!"
		end
		basename = File.basename(csvfile, ".csv")
		case basename
		#处理角色名，用来随机用
		when 'JiaoSeMing'
			initPlayerNameMetaData(csvfile)
		#英雄配表
		when 'WuJiang'
			@heroMetaMap = {}
			initMetaData(csvfile,@heroMetaMap,"generalID")
			#自有兵法列表
			@selfBookList = []
			@heroMetaMap.each_value do |hero| 
				selfBook = hero.gInitialWarcraft.to_i
				if selfBook > 0 and not @selfBookList.include?(selfBook)
					@selfBookList << selfBook
				end
			end #generalID 
		#招募配表
		when 'ZhaoMu'
			@recuriteMetaMap = {}
			initMetaData(csvfile,@recuriteMetaMap,"recruitName")
		#情义（命运）
		when 'MingYun'
			@fateMetaMap = {}
			initMetaData(csvfile,@fateMetaMap,"fateID")
		#角色级别与经验值
		when 'JiaoSeShengJiJingY'
			@playerLevelMetaMap = {}
			initMetaData(csvfile, @playerLevelMetaMap ,"characterLevel")
		#英雄级别与经验值配表
		when 'WuJiangDengJi'
			@heroLevelMetaMap = {}
			initMetaData(csvfile, @heroLevelMetaMap ,"levelGeneral")
		#英雄进阶
		when 'WuJiangJinJie'
			@heroAdancedLevelMetaMap = {}
			initMetaData(csvfile, @heroAdancedLevelMetaMap ,"advancedTime")
		#装备-武器防具坐骑
		when 'ZhuangBei'
			@equipmentMap = {}
			initMetaData(csvfile, @equipmentMap ,"equipmentID")
		#兵法
		when 'BingFa'
			@bookMap = {}
			initMetaData(csvfile,@bookMap,"bookID")
		#宝物
		when 'DaoJu'	
			@propMap = {}
			initMetaData(csvfile,@propMap,"propID")
		when 'PeiYang'
			initHeroBringupMetaData(csvfile)
		#VIP表
		when 'Vip'
			@vipMap = {}
			initMetaData(csvfile,@vipMap,"vipLevel")
		#强化表
		when 'ZhuangBeiQiangHua'
			@strengthenMap = {}
			initStrengthenMapMetaData(csvfile,@strengthenMap)
		#进阶表
		when 'BingFaJinJie'
			@bookAdvancedMap = {}
			initBookAdvancedMapMetaData(csvfile,@bookAdvancedMap)
		#兵法碎片
		when 'BingFaSuiPian'
			@bookFragment = {}
			initMetaData(csvfile,@bookFragment,"fragmentID")
		#flag ， 游戏配置，标记 等表
		when 'Flag'
			@flagMap = {}
			initMetaData(csvfile,@flagMap,"name")
		when 'ZhanYi'
			initBattle(csvfile)
		when 'NPC'
			@npcMetaMap = {}
			initMetaData(csvfile, @npcMetaMap, "npcID")
		when 'ChengZhangRenWu'
			initTaskMetaData(csvfile)
		else
		end
	end


	#初始化任务量表
	def initTaskMetaData(csvfile)
		#sort:[temp,temp]
		@taskSortDataMap = {}
		@fstTaskBySortWithStatus = {}
		#所有的任务
		@taskMap = {}
		#所有的任务类型
		@taskSort = []
		allRows = CSV.read(csvfile,{:col_sep=>";"})
		if allRows and not allRows.empty?
			title = allRows[1]
			allRows.each_with_index do |row,i|
				if i > 1
					metaData = Model::MetaData.new(title,row)
					@taskMap[metaData.questID] = metaData
					#分类
					if not @taskSort.include?(metaData.qType)
						@taskSort << metaData.qType
						@fstTaskBySortWithStatus[metaData.questID.to_s] = Const::StatusDisable
					end
					#任务分类
					list = @taskSortDataMap[metaData.qType]
					if list == nil
						list = Array.new
					end
					list << metaData
					@taskSortDataMap[metaData.qType] = list
				end
			end
		end
	end


	# read character name from csv file for generate random name
	# @param [String] csvfile , the path of csv file
	# @return nothing
	def initPlayerNameMetaData(csvfile)
		@playerFirstName = []
		@playerSecondNameMale = []
		@playerSecondNameFemale = []
		allRows = CSV.read(csvfile,{:col_sep=>";"})
		if allRows and not allRows.empty?
			title = nil
			allRows.each_with_index do |row,i|
				if i > 1
					@playerFirstName.push(row[0]) unless row[0] == nil
					@playerSecondNameMale.push(row[1]) unless row[1] == nil
					@playerSecondNameFemale.push(row[2]) unless row[2] == nil
				end
			end
		end
	end
	#初始化成长表
	#@param [String] csv file 
	#@return
	def initHeroBringupMetaData(csvfile)
		@bringUpMap = {}
		allRows = CSV.read(csvfile,{:col_sep=>";"})
		if allRows and not allRows.empty?
			title = allRows[1]
			allRows.each_with_index do |row,i|
				if i > 1
					metaData = Model::MetaData.new(title,row)
					if not @bringUpMap.key?(metaData.cultureType)
						@bringUpMap[metaData.cultureType] = []
					end
					@bringUpMap[metaData.cultureType] << metaData
				end
			end
		end
	end
	# 初始化强化量表 key = level+"_"+star
	# @param [String,Hash] csvfile , the path of csv file metamap ,the Hash data store meta data
	# @return nothing
	def initStrengthenMapMetaData(csvfile,metamap )
		@equipMaxLevel = 0 
		allRows = CSV.read(csvfile,{:col_sep=>";"})
		if allRows and not allRows.empty?
			title = allRows[1]
			allRows.each_with_index do |row,i|
				if i > 1
					metaData = Model::MetaData.new(title,row)
					#装备的最大等级
					@equipMaxLevel = metaData.equipmentLevel.to_i unless @equipMaxLevel > metaData.equipmentLevel.to_i
					key = metaData.equipmentLevel + "_" + metaData.eStarLevel
					metamap[key] = metaData
				end
			end
		end
	end

	# 初始化兵法进阶量表 key = level+"_"+star
	# @param [String,Hash] csvfile , the path of csv file metamap ,the Hash data store meta data
	# @return nothing
	def initBookAdvancedMapMetaData(csvfile,metamap )
		@bookMaxLevel = 0 
		allRows = CSV.read(csvfile,{:col_sep=>";"})
		if allRows and not allRows.empty?
			title = allRows[1]
			allRows.each_with_index do |row,i|
				if i > 1
					metaData = Model::MetaData.new(title,row)
					key = metaData.bLevel + "_" + metaData.bookStar
					metamap[key] = metaData
					#装备的最大等级
					level = metaData.bLevel.to_i
					if @bookMaxLevel < level 
						@bookMaxLevel = level 
					end
				end
			end
			#最大等级
			@bookMaxLevel = @bookMaxLevel + 1
		end
	end


	# read meta data from csvfile
	# @param [String,Hash] csvfile , the path of csv file metamap ,the Hash data store meta data
	# @return nothing
	def initMetaData(csvfile,metamap,keyfield)
		allRows = CSV.read(csvfile,{:col_sep=>";"})
		if allRows and not allRows.empty?
			title = allRows[1]
			allRows.each_with_index do |row,i|
				if i > 1
					metaData = Model::MetaData.new(title,row)
					key = metaData.send(keyfield)
					metamap[key] = metaData
				end
			end
		end
	end
	# 初始化战役表
	# @param [file]
	# @return nothing
	def initBattle(csvfile)
		@battleMetaMap = {}
		@subBattleMetaMap = {}
		allRows = CSV.read(csvfile,{:col_sep=>";"})
		if allRows and not allRows.empty?
			title = allRows[1]
			allRows.each_with_index do |row,i|
				if i > 1
					metaData = Model::MetaData.new(title,row)
					if not @battleMetaMap.key?(metaData.battlefirstID)
						@battleMetaMap[metaData.battlefirstID] = []
					end
					@battleMetaMap[metaData.battlefirstID] << metaData
					@subBattleMetaMap[metaData.bSubID] = metaData
				end
			end
		end
	end
	# get hero meta data 
	def getHeroMetaData(herotempleteid)
		@heroMetaMap[herotempleteid.to_s]
	end
	# generate player name random
	# @param [String] player gender
	# @return [String] player name
	def generatePlayerName(gender)
		if gender == "male"
			"#{@playerFirstName.sample}#{@playerSecondNameMale.sample}"
		else
			"#{@playerFirstName.sample}#{@playerSecondNameFemale.sample}"
		end
	end
	#处理招募武将的配表
	def getRecuriteMetaData(key)
		@recuriteMetaMap[key.to_s]
	end
	#处理角色信息的配表
	def getPlayerLevelMetaData(key)
		@playerLevelMetaMap[key.to_s]
	end
	#处理英雄等级的配表
	def getHeroLevelMetaData(key)
		@heroLevelMetaMap[key.to_s]
	end
	#取英雄的最大等级
	def getMaxHeroLevel()
		@heroLevelMetaMap.length()
	end
	#取英雄经验的列表
	def getAllHeroLevelMetaData()
		@heroLevelMetaMap.values()
	end
	#取角色经验的列表
	def getAllPlayerLevelMetaData()
		@playerLevelMetaMap.values()
	end
	#取最大的进阶级别
	def getMaxHeroAdvancedLevel()
		advancedLevels = @heroAdancedLevelMetaMap.values()
		advancedLevels[advancedLevels.length - 1].advancedTime.to_i
	end
	#取进阶配置信息
	def getAdancedHeroLevelMetaData(key)
		@heroAdancedLevelMetaMap[key.to_s]
	end

	#取英雄的最大等级
	def getMaxPlayerLevel()
		@playerLevelMetaMap.length()
	end

	#
	#道具信息
	#
	def getTempItem(iid)
		#武器防具坐骑
		tempItem = @equipmentMap[iid.to_s]
		if tempItem
			return tempItem 
		end
		#兵法
		tempItem = @bookMap[iid.to_s]
		if tempItem
			tempItem.eType = Const::ItemTypeBook
			return tempItem 
		end
		#宝物
		tempItem = @propMap[iid.to_s]
		if tempItem
			tempItem.eType = Const::ItemTypeProp
			return tempItem 
		end
		#不存在
		if ! tempItem
			GameLogger.debug("MetaDao.getTempItem method params iid:#{iid} => tempItem is not exists !")
		end
		tempItem
	end

	#武器防具坐骑
	def getEquipMetaData(iid)
		return @equipmentMap[iid.to_s]
	end
	#兵法
	def getBookMetaData(iid)
		return @bookMap[iid.to_s]
	end

	# 获取强化配置
	# @param [Integer,Integer] level , star
	# @return 
	def getStrengthenMetaData(level,star)
		key = level.to_s + "_" + star.to_s
		@strengthenMap[key]
	end

	#装备的最大等级
	#@return [Integer]
	def getEquipMaxLevel
		@equipMaxLevel
	end


	#vip meta data
	def getVipMetaData(vip)
		@vipMap[vip.to_s]
	end

	# 获取进阶配置
	# @param [Integer,Integer] level , star
	# @return 
	def getBookAdvancedMetaData(level,star)
		key = level.to_s + "_" + star.to_s
		@bookAdvancedMap[key]
	end


	#兵法最高等级
	#@return [Integer]
	def getBookMaxLevel
		@bookMaxLevel
	end

	#自有兵法列表
	def getSelfBookList
		@selfBookList
	end

	#获取flag表里的游戏配置
	def getFlagValue(key)
		@flagMap[key].value
	end

	#兵法碎片
	#@param [Integer] 兵法碎片
	#@return [Hash] 
	def getBookFragmentMetaData(bookIid)
		@bookFragment[bookIid.to_s]
	end



	#根据类型获取培养参数
	#@param[Integer]
	#@return metadata
	def getHeroBringupMetaData(bringtype)
		heroBringUpList = nil
		if bringtype == Const::HeroBringUpNormal or bringtype == Const::HeroBringUpNormalTen
			heroBringUpList = @bringUpMap["1"]
		else
			heroBringUpList = @bringUpMap["2"]
		end
		rates = []
		heroBringUpList.each do |bringUpMeta|
			rates << bringUpMeta.cRuleProbability.to_i
		end
		index = Utils::Random.randomIndex(rates)
		heroBringUpList[index]
	end
	# 根据大战役的id获得战役列表
	# @param [Integer]
	# @return [Array]
	def getSubBattleListById(battleId)
		@battleMetaMap[battleId.to_s]
	end
	#取游戏大类列表
	# @param
	# @return 
	def getBattleList
		battleList = []
		battleIdList = @battleMetaMap.keys()
		battleIdList.each do |battleId|
			subMetaBattle = @battleMetaMap[battleId][0]
			battle = {:battleId => battleId, :battleName => subMetaBattle.bName,:battleDes => subMetaBattle.bDesc}
			battleList << battle
		end
		battleList
	end
	# 取大战役的列表
	# @param
	# @return [Array]
	def getBattleIdList
		@battleMetaMap.keys
	end
	#取子战役信息
	# @param[Integer]
	# @return [MetaData]
	def getSubBattleMetaData(subBattleId)
		@subBattleMetaMap[subBattleId.to_s]
	end

	#获取任务配置信息
	def getTaskMetaData(iid)
		@taskMap[iid.to_s]
	end

	#任务类型列表
	def getTaskTypeList()
		@taskSort
	end

	#返回每种类型的任务第一个iid，及其状态
	#@param 
	#@return [Hash] iid:status 
	def getFstTaskBySortWithStatus()
		@fstTaskBySortWithStatus
	end

	#返回某种类型的所有任务
	#@param [Integer] sort
	#@return [Array]
	def getTaskListBySort(sort)
		@taskSortDataMap[sort]
	end
	#返回某个NPC的配置数据
	#@param [Integer] 
	#@return [MetaData]
	def getNPC(npcId)
		@npcMetaMap[npcId.to_s]
	end

	def getAllHeroTempId()
		@heroMetaMap.keys
	end

end