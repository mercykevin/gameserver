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
		@heroMetaMap[herotempleteid]
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

	def getRecuriteMetaData(key)
		@recuriteMetaMap[key]
	end
end