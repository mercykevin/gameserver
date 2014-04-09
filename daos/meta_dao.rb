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
		when 'CharacterName'
			initPlayerNameMetaData(csvfile)
		#英雄配表
		when 'Generals'
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
		when 'Recruit'
			@recuriteMetaMap = {}
			initMetaData(csvfile,@recuriteMetaMap,"recruitName")
		#情义
		when 'Fate'
			@fateMetaMap = {}
			initMetaData(csvfile,@fateMetaMap,"fateID")
		#角色级别与经验值
		when 'CharacterLevel'
			@playerLevelMetaMap = {}
			initMetaData(csvfile, @playerLevelMetaMap ,"characterLevel")
		#英雄级别与经验值配表
		when 'GeneralLevel'
			@heroLevelMetaMap = {}
			initMetaData(csvfile, @heroLevelMetaMap ,"levelGeneral")
		#英雄进阶
		when 'GenneralAdvanced'
			@heroAdancedLevelMetaMap = {}
			initMetaData(csvfile, @heroAdancedLevelMetaMap ,"advancedTime")
		#装备-武器防具坐骑
		when 'Equipment'
			@equipmentMap = {}
			initMetaData(csvfile, @equipmentMap ,"equipmentID")
		#兵法
		when 'Book'
			@bookMap = {}
			initMetaData(csvfile,@bookMap,"bookID")
		#宝物
		when 'Prop'	
			@propMap = {}
			initMetaData(csvfile,@propMap,"propID")
		when 'CultureValue'
			initHeroBringupMetaData(csvfile)
		#VIP表
		when 'Vip'
			@vipMap = {}
			initMetaData(csvfile,@vipMap,"vipLevel")
		#强化表
		when 'Strengthen'
			@strengthenMap = {}
			initStrengthenMapMetaData(csvfile,@strengthenMap)
		#进阶表
		when 'BookAdvanced'
			@bookAdvancedMap = {}
			initBookAdvancedMapMetaData(csvfile,@bookAdvancedMap)
		#兵法碎片
		when 'BookFragment'
			@bookFragment = {}
			initMetaData(csvfile,@bookFragment,"fragmentID")
		#flag ， 游戏配置，标记 等表
		when 'Flag'
			@flagMap = {}
			initMetaData(csvfile,@flagMap,"name")
		else
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
					@equipMaxLevel = metaData.equipmentLevel.to_i unless @equipMaxLevel > metaData.eStarLevel.to_i
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
			puts @bookMaxLevel
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
	#取最大的进阶级别
	def getMaxHeroAdvancedLevel()
		advancedLevels = @heroAdancedLevelMetaMap.values()
		advancedLevels[advancedLevels.length - 1].advancedTime.to_i
	end
	#取进阶配置信息
	def getAdancedHeroLevelMetaData(key)
		@heroAdancedLevelMetaMap[key.to_s]
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
		@flagMap[key.to_s].value
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


end