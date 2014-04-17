require File.expand_path("../../test_helper",__FILE__)
require 'json'
class HeroTest < Minitest::Test



	# def test_addItem
	# 	player = Model::Player.register("andy","image")[:player]
		
	# 	puts "添加宝物"
	# 	playerId = player[:playerId]
	# 	iid = 200000
	# 	count = 5
	# 	Model::Item.addItem(player,iid,count)
		
 # 		puts "追加宝物"
	# 	count = 5
	# 	Model::Item.addItem(player,iid,count)
		
	# 	puts "第二个宝物"
	# 	iid = 200001
	# 	count = 5
	# 	Model::Item.addItem(player,iid,count)

	# 	propList = Model::Item.getPropList(1)  
	# 	puts "宝物列表	#{propList.to_json}"

	# 	puts "--------------------------------兵法"	
	# 	puts "添加兵法	"
	# 	count = 5 
	# 	iid = 500001
	# 	Model::Item.addItem(player,iid,count)
		
	# 	puts "--------------------------------装备类"

	# 	puts "添加武器"
	# 	count = 2
	# 	iid = 400001
	# 	Model::Item.addItem(player,iid,count)

	# 	puts "添加防具"
	# 	count = 2
	# 	iid = 420806
	# 	Model::Item.addItem(player,iid,count)


	# 	puts "添加坐骑"	
	# 	count = 5 
	# 	iid = 430109
	# 	Model::Item.addItem(player,iid,count)
	
	# 	itemList = Model::Item.getEquipUnusedList(playerId,Const::ItemTypeWeapon)  
	# 	puts "武器列表 #{itemList}"
		
	# 	itemList = Model::Item.getEquipeAllList(playerId)  
	# 	puts "装备列表 #{itemList.size} #{itemList}"

	# end

	# def test_getEquip
	# 	player = Model::Player.register("andy","image")[:player]
	# 	playerId = player[:playerId]
	# 	id = 1
	# 	count = 1
	# 	iid = 400001
	# 	Model::Item.addItem(player,iid,count)
	# 	equipData = Model::Item.getEquipmentData(playerId,id)

	# 	puts "获取装备信息	#{equipData}"
	# 	puts "获取装备iid	 #{equipData[:iid]}"	
	# 	puts "获取装备star	#{equipData[:star]}"
	# end


	# def test_keys_time
	# 	a  = Time.now.to_i
	# 	player = Model::Player.register("andy","image")[:player]
	# 	playerId = player[:playerId]
	# 	count = 5
	# 	iid = 400001
	# 	puts "开始添加装备。。。"
	# 	Model::Item.addItem(player,iid,count)
	# 	b  = Time.now.to_i
	# 	puts "追加装备 耗时	#{a-b}"

	# end


	# def test_getProp
	# 	player = Model::Player.register("andy","image")[:player]
	# 	playerId = player[:playerId]
	# 	iid = 200000
	# 	count = 1111
	# 	Model::Item.addItem(player,iid,count)
	# 	puts "添加宝物"
	# 	propData = Model::Item.getPropData(playerId,iid)	
	# 	puts "宝物数量	#{propData[:count]}"
	# end


	# def test_getPropList
	# 	player = Model::Player.register("andy","image")[:player]
	# 	playerId = player[:playerId]
	# 	iid = 200001
	# 	count = 100
	# 	Model::Item.addItem(player,iid,count)
	# 	propList = Model::Item.getPropList(1)  
	# 	puts "宝物列表	#{propList.to_json}"
	# end




	# #强化装备
	# def test_strengthenEquip
	# 	equipId  = 1
	# 	iid = 410101
	# 	count = 2
	# 	player = Model::Player.register("andy","image")[:player]
	# 	player[:siliver] =100000
	# 	Model::Item.addItem(player,iid,count)
	# 	equipData = Model::Item.getEquipmentData(player[:playerId],equipId)
	# 	puts "强化前装备	#{equipData}"
	# 	puts "强化前player	#{player}"
	# 	ret = Model::Item.strengthenEquip(player,equipId)
	# 	puts "强化后装备	iid#{iid} , ret: #{ret}"
	# 	puts "强化后player	#{player}"
	# end

	##测试的话，单独测试这一个，id是写死的 !
	# def test_advanceBook
	# 	equipId  = 1
	# 	iid = 500077#兵法
	# 	count = 6
	# 	player = Model::Player.register("andy","image")[:player]

	# 	Model::Item.addItem(player,iid,count)
		
	# 	bookData = Model::Item.getBookData(player[:playerId],equipId)
	# 	puts "进阶前兵法	#{bookData}"

	# 	ret = Model::Item.preAdvanceBookService(player , 1 , "2")
	# 	puts "进阶预览：#{ret}"

	# 	ret = Model::Item.advanceBook(player , 1 , "2,3")
	# 	puts "进阶返回信息 :#{ret}"
	# 	bookData = Model::Item.getBookData(player[:playerId],equipId)
	# 	puts "进阶后player:#{player}"

	# 	 list= Model::Item.autoChooseBooks(player[:playerId])
	# 	 puts "list - - - - - #{list}"
	# end

	# def test_calcBuff
	# 	bookBuff = Model::Item.calcBookBuff(500002 , 2)
	# 	puts "bookBuff #{bookBuff}"
	# 	equipBuff = Model::Item.calcEquipBuff(400001 , 2)
	# 	puts "equipBuff #{equipBuff}"
	# end

	# def test_addItemForTest
	# 	player = Model::Player.register("andy","image")[:player]
	# 	playerId = player[:playerId]
	# 	Model::Item.addItem4Test(player)

	# 	itemList = Model::Item.getEquipUnusedList(playerId,Const::ItemTypeWeapon)  
	# 	puts "装备列表 #{itemList}"
	# 	itemList = Model::Item.getEquipUnusedList(playerId,Const::ItemTypeShield)  
	# 	puts "防具 #{itemList}"
	# 	itemList = Model::Item.getEquipUnusedList(playerId,Const::ItemTypeBook)  
	# 	puts "兵法 #{itemList}"
	# end


	# def test_extendPackCell
	# 	player = Model::Player.register("andy","image")[:player]
	# 	puts "扩展背包前：#{player}"
	# 	ret = Model::Item.extendPackCell(player) 
	# 	puts "扩展背包后： ret:#{ret} #{player}"
	# end

	def test_sort
		player = Model::Player.register("andy","image")[:player]
		playerId = player[:playerId]
		puts "添加兵法	"

		count = 2
		iid = 500070
		Model::Item.addItem(player,iid,count)
		count = 1
		iid = 500089
		Model::Item.addItem(player,iid,count)
		count = 2
		iid = 500001
		Model::Item.addItem(player,iid,count)
		count = 1
		iid = 500015
		Model::Item.addItem(player,iid,count)
	
		itemList = Model::Item.getEquipUnusedList(playerId,Const::ItemTypeBook)  
		puts "排序前兵法 #{itemList}"
		
		itemList = Model::Item.sortEquipByStar(itemList)

		puts "排序前兵法 #{itemList}"


		list =  Model::Item.autoChooseBooks(playerId)
		puts "一键选择：#{list.size} #{list}"
		
	end


end