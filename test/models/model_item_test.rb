require File.expand_path("../../test_helper",__FILE__)
require 'json'
class HeroTest < Minitest::Test

	def test_addEquip
		playerId = 1
		iid = 400001
		count = 1
		Model::Item.addEquip(playerId,iid,count)
		puts "添加装备"
	end

	def test_getEquip
		playerId = 1
		id = 1
		count = 1
		iid = 400001
		Model::Item.addEquip(playerId,iid,count)
		equipData = Model::Item.getEquip(playerId,id)
		puts "获取装备1	#{equipData}"
		puts "获取装备iid	#{equipData[:iid]}"
		puts "获取装备star	#{equipData[:star]}"
	end

	def test_addProp
		playerId = 1
		iid = 400001
		count = 1
		Model::Item.addProp(playerId,iid,count)
		puts "添加宝物	+1"
		count = 9
		Model::Item.addProp(playerId,iid,count)
		puts "追加宝物 	+9"
	end

	def test_getProp
		playerId = 100
		iid = 400001
		count = 1111
		Model::Item.addProp(playerId,iid,count)
		puts "添加宝物"
		propData = Model::Item.getProp(playerId,iid)	
		puts "宝物数量	#{propData[:count]}"
	end


	def test_getPropList
		propList = Model::Item.getPropList(1)  
		propList.to_json
	end

	def test_getEquipUnusedList
		itemList = Model::Item.getEquipUnusedList(1)  
		itemList.to_json
	end

	def test_getEquipUsedList
		itemList = Model::Item.getEquipUsedList(1,1)  
		itemList.to_json
	end


end