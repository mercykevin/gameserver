require File.expand_path("../../test_helper",__FILE__)
require 'json'
class HeroTest < Minitest::Test


	# def test_test
	# 	a = [1,2,3,4,"2"]
	# 	b = 1
	# 	c = a.include?(b)
	# 	puts "include	#{c}"
	# 	d = "2"
	# 	c = a.include?(d)
	# 	puts "include	#{c}"
	# end


	def test_random
		for i in 0..20 do 
			num =  Utils::Random::randomValue([10,1,3,3,10] , [10,20,30,40,50])
			puts "#{num}" 
			# index =  Utils::Random::randomIndex([1,2,3,4,5] )
			# puts "返回数值	#{index}" 
			
		end

	end


end