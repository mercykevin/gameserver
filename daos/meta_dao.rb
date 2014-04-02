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
		when 'CharacterName'
			initPlayerNameMetaData(csvfile)
		when 'Generals'
			@heroMetaMap = {}
			initMetaData(csvfile,@heroMetaMap,"generalID")
		when 'Recruit'
			@recuriteMetaMap = {}
			initMetaData(csvfile,@recuriteMetaMap,"recruitName")
		when 'Fate'
			@fateMetaMap = {}
			initMetaData(csvfile,@fateMetaMap,"fateID")
		when 'CharacterLevel'
			@playerLevelMetaMap = {}
			initMetaData(csvfile, @playerLevelMetaMap ,"characterLevel")
		when 'GeneralLevel'
			@heroLevelMetaMap = {}
			initMetaData(csvfile, @heroLevelMetaMap ,"levelGeneral")
		when 'GenneralAdvanced'
			@heroAdancedLevelMetaMap = {}
			initMetaData(csvfile, @heroAdancedLevelMetaMap ,"advancedTime")
		#装备
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
		else


		end
	end
	# read character name from csv file for generate random name
	# @param [String] csvfile , the path of csv file
	# @return nothing
	##
	
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
		tempItem = @propMap[iid.to_s]
		 
		if tempItem
			return tempItem 
		end
		
		tempItem = @equipmentMap[iid.to_s]
		if tempItem
			return tempItem 
		end

		tempItem = @bookMap[iid.to_s]
		if tempItem
			return tempItem 
		end

		tempItem = @propMap[iid.to_s]
		if tempItem
			return tempItem 
		end

		if ! tempItem
			GameLogger.debug("MetaDao.getTempItem method params iid:#{iid} => tempItem is not exists !")
		end

		tempItem
		
	end


end