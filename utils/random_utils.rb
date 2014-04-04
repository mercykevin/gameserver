#用来处理所有redis存储的key值
module Utils
	class Random


		#根据权重列表，返回数值
		# [1,2,3,4,5]
		# [10,10,20,20,40]
		# [0,10),[10,20),[20,40),[40,60),[60,100)]
		#
		#@param [Array , Array]
		#@return [Integer]
		def self.randomValue(rates , vals)
			if rates.length != vals.length
   				raise ExceptionConst::DoNotMatchTheLengthOfTheArray
   			end
			index = randomIndex(rates)
			vals[index]
		end

		#根据权重列表，返回索引
		# [1,2,3,4,5]
		# [10,10,20,20,40]
		# [0,10),[10,20),[20,40),[40,60),[60,100)]
		#
		#@param [Array , Array]
		#@return [Integer]
		def self.randomIndex(rates)
			total = 0
			#区间界限
			rangArr = []
			for i in 0..rates.length-1 do
				rate = rates[i]
				if i ==0 
					rangArr.push([0 , rates[0]])
				else
					rangArr.push([total , total + rates[i]])
				end
				total += rate
			end

			index = 0 
			randNum = rand(total)

			for i in 0..rangArr.length - 1 do
				rang  = rangArr[i]
				
				if randNum >= rang[0] and randNum < rang[1]
					index = i
					break
				end
			end
			index
		end

	end
end