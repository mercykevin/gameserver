require File.expand_path("../../test_helper",__FILE__)
require 'json'
class RandomTest < Minitest::Test


	# def test_test
	# 	a = [1,2,3,4,"2"]
	# 	b = 1
	# 	c = a.include?(b)
	# 	puts "include	#{c}"
	# 	d = "2"
	# 	c = a.include?(d)
	# 	puts "include	#{c}"
	# end


	# def test_random
	# 	for i in 0..20 do 
		
	# 		index =  Utils::Random::randomIndex([1,2,3,4,5] )
	# 		puts "随机索引	#{index}" 
	# 		num =  Utils::Random::randomValue([10,1,3,3,10] , [10,20,30,40,50])
	# 		puts "随机数值 	#{num}" 
	# 		num =  Utils::Random::randomValue([10,1,3,3,10,5] , [10,20,30,40,50])
			
	# 	end
	#end


	# def test_each_key
	# 	json = "{\"item\":{\"10100\":10}}"
	# 	val = JSON.parse(json)
	# 	val.each_key do |k|
	# 		puts "key : #{k}   value : #{val[k]}"
	# 	end
	# 	puts " 转换后 #{val}"
	# 	puts " keys #{val.keys}"
	# 	puts " keys #{val.values}"
	# end



	def test_append_id

		equip = {}
		equip[:id] = 1
		equip[:level] = 2
		equip[:star] = 5
		id = Model::Item.calcEquipSortId(equip)
		puts "id #{id}"

		equip = {}
		equip[:id] = 1111122222
		equip[:level] = 150
		equip[:star] = 6
		id = Model::Item.calcEquipSortId(equip)
		puts "id #{id}"


	end




end