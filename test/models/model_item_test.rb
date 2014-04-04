require File.expand_path("../../test_helper",__FILE__)
require 'json'
class HeroTest < Minitest::Test



	# def test_addItem

	# 	playerId = 1
	# 	iid = 200000
	# 	count = 10
	# 	Model::Item.addItem(playerId,iid,count)
	# 	puts "添加宝物	+10"
 
	# 	count = 15
	# 	Model::Item.addItem(playerId,iid,count)
	# 	puts "追加宝物 	+15"


	# 	count = 2
	# 	iid = 400001
	# 	Model::Item.addItem(playerId,iid,count)
	# 	puts "添加装备	"

	# 	count = 1 
	# 	iid = 400001
	# 	Model::Item.addItem(playerId,iid,count)
	# 	puts "追加装备	"

	# 	count = 5 
	# 	iid = 500001
	# 	Model::Item.addItem(playerId,iid,count)
	# 	puts "添加兵法	"

	# end

	# def test_getEquip
	# 	playerId = 1
	# 	id = 1
	# 	count = 1
	# 	iid = 400001
	# 	Model::Item.addItem(playerId,iid,count)
	# 	equipData = Model::Item.getEquipData(playerId,id)
	# 	puts "获取装备	#{equipData}"
	# 	puts "获取装备iid	#{equipData[:iid]}"
	# 	puts "获取装备star	#{equipData[:star]}"
	# end


	# def test_getProp
	# 	playerId = 100
	# 	iid = 200000
	# 	count = 1111
	# 	Model::Item.addItem(playerId,iid,count)
	# 	puts "添加宝物"
	# 	propData = Model::Item.getPropData(playerId,iid)	
	# 	puts "宝物数量	#{propData[:count]}"
	# end


	# def test_getPropList
	# 	playerId = 1
	# 	iid = 400001
	# 	count = 100
	# 	Model::Item.addItem(playerId,iid,count)

	# 	propList = Model::Item.getPropList(1)  
	# 	puts "宝物列表	#{propList.to_json}"
	# end

	# def test_getEquipUnusedList
	# 	itemList = Model::Item.getEquipUnusedList(1,1)  
	# 	itemList.to_json
	# end



	#==============
	#强化装备
	# def test_strengthenEquip
	# 	equipId  = 1
	# 	iid = 400001
	# 	count = 2
	# 	player = Model::Player.register("andy","image")[:player]
	# 	player[:silver] =100000
	# 	Model::Item.addItem(player[:playerId],iid,count)
	# 	ret = Model::Item.strengthenEquip(player,equipId)
	# 	puts "强化装备	iid#{iid} , ret: #{ret}"
	# end





end