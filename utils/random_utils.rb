#计算概率
module Utils
	class Random

		#根据权重列表，返回索引
		#权重为0就随机不到该索引
		#@param [Array] 权重列表，之和不一定必须 100
		#@return [Integer] 返回索引
		def self.randomIndex(rateArr)
			total = 0
			#区间界限
			rangArr = []
			for i in 0..rateArr.length-1 do
				rate = rateArr[i].to_i
				if i ==0 
					rangArr.push([0 , rateArr[0].to_i])
				else
					rangArr.push([total , total + rateArr[i].to_i])
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

		#根据权重列表，返回数值
		#权重为0就随机不到该索引
		#@param [Array , Array] 权重列表，对应值列表
		#@return [Integer] 返回值
		def self.randomValue(rateArr , valArr)
			if rateArr.length != valArr.length
   				raise ExceptionConst::DoNotMatchTheLengthOfTheArray
   			end
			index = randomIndex(rateArr)
			valArr[index]
		end

		#权重字符串，逗号分隔，返回值
		#@param [String,String] rateStrs 权重字符串逗号分隔，valStrs 格式同rateStrs 
		#@return valStrs 的随机元素
		def self.randomValueByStr(rateStrs , valStrs)
			index = randomIndex(rateStr.split(","))
			valStrs.split(",")[index]
		end

	end
end