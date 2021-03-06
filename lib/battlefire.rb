module Model
	class BattleFire
		# 构造函数
		# @params[Array,Array,Integer,String] 进攻方，防守方 
		def initialize(attack, attackPlayer, defend, defendPlayer)
			@attack = attack
			@attackCount = attack.length
			@attackPlayer = attackPlayer
			@defend = defend
			@defendPlayer = defendPlayer
			#战斗回合
			@round = 1
			#当前行动方,是否是进功方进攻，如果是false的话，就是防守方行动，打
			@actionSide = true
			@attackOne = nil
			@defendOne = nil
			#初始化战斗报告
			@report = {}
			#深度拷贝
			@report[:attack] = Marshal.load(Marshal.dump(attack))
			@report[:defend] = Marshal.load(Marshal.dump(defend))
			@report[:battleproc] = {}
			#战斗结果
			@result = {}
		end
		#
		# 处理战斗逻辑
		def pk()
			while not @attack.empty? and not @defend.empty? do
				#战斗没结束
				if @attack.values[-1][:isAction] and @defend.values[-1][:isAction]
					#一回合已经结束
					reset()
				end
				#获取行动方战斗单位
				if @actionSide
					#进攻方行动
					@attackOne = pickActionOne(@attack)
					@defendOne = pickReceiveOne(@attackOne[:index], @defend)
					calculateBattle(@attackOne, @defendOne)
				else
					#防守方行动
					@defendOne = pickActionOne(@defend)
					@attackOne = pickReceiveOne(@defendOne[:index], @attack)
					calculateBattle(@defendOne, @attackOne)
				end
				#没血了
				if @attackOne[:blood] == 0
					@attack.delete(@attackOne[:index])
				end
				if @defendOne[:blood] == 0
					@defend.delete(@defendOne[:index])
				end
				#处理后续
				#行动方轮换
				@actionSide = (not @actionSide)
				@attackOne = nil
				@defendOne = nil
			end
		end
		# 处理战斗结果
		# 星级,奖励相关
		#
		def handleResult()
			@result[:win] = false
			@result[:stars] = 0
			if @attack.empty?
				@result[:win] = false 
			else
				@result[:win] = true
				#处理星级 TODO，要修改
				if @attack.length == @attackCount
					@result[:stars] = 3
				else
					@result[:stars] = 2
				end
			end
		end
		#获取战报
		def getReport()
			@report[:result] = @result
			@report
		end
		#一回合结束，reset相应的数据
		def reset()
			#重置行动标识
			@attack.values.each do |temp|
				temp[:isAction] = false
			end
			@defend.values.each do |temp|
				temp[:isAction] = false
			end
			#重置行动方
			@actionSide = true
			#回合数+1
			@round = @round + 1
		end
		#是否赢了比赛
		def isWin()
			@result[:win]
		end
		#处理行动方的战斗单元
		def pickActionOne(actions)
			actions.each_pair do |k,v|
				#没有行动过
				if not v[:isAction]
					return v
				end
			end 
		end
		#获取星级
		def getStars()
			@result[:stars]
		end
		def getPkResult()
			@result
		end
		#选择受伤方
		def pickReceiveOne(actionIndex, receivers)
			#处理同一排的
			if actionIndex % 2 == 0
				#第一排 0, 2, 4, 6
				if receivers[actionIndex]
					return receivers[actionIndex]
				else
					if receivers[actionIndex + 1]
						return receivers[actionIndex + 1]
					end
				end				
			else
				#第二排1, 3, 5, 7
				if receivers[actionIndex - 1]
					return receivers[actionIndex - 1]
				else
					if receivers[actionIndex]
						return receivers[actionIndex]
					end
				end
			end
			#对应的同排都没的话，开始往外扩散找，找离自己最近的
			#先往后找
			finderAfter = nil
			beginIndex = 0
			beforeBeginIndex = 0
			if actionIndex % 2 == 0
				#第一排
				beginIndex = actionIndex + 2
				beforeBeginIndex = actionIndex - 2
			else
				#第二排
				beginIndex = actionIndex + 1
				beforeBeginIndex = actionIndex - 3
			end
			(beginIndex..7).each do |index|
				if receivers[index]
					finderAfter = receivers[index]
					break
				end
			end
			#往前找
			finderBefore = nil
			while beforeBeginIndex >=0 do 
				(beforeBeginIndex..beforeBeginIndex + 1).each do |index|
					if receivers[index]
						finderBefore = receivers[index]
						break
					end
				end
				if finderBefore
					beforeBeginIndex ＝ -1
				end
				#步进值减2
				beforeBeginIndex = beforeBeginIndex - 2
			end
			if finderAfter or finderBefore
				if finderAfter and finderBefore
					#都有的话，看谁最近
					if (finderAfter[:index] - actionIndex).abs <= (finderBefore[:index] - actionIndex).abs
						return finderAfter
					else
						return finderBefore
					end
				else
					if finderAfter
						return finderAfter
					else
						return finderBefore
					end
				end
			end
		end
		#战斗计算
		#@params[Hash,Hash]
		#@return nothing
		def calculateBattle(actionOne,receiveOne)
			report = {}
			oldBlood = receiveOne[:blood]
			a = 200 * 0.06 * actionOne[:level] * 0.25
			b = 200 * 0.06 * receiveOne[:level] * 0.1
			k = 0
			hurt =  actionOne[:attack] * 5 + rand(a) - (receiveOne[:defend] * 2.5 + rand(b)) + k
			receiveOne[:blood] = [0, receiveOne[:blood] - hurt].max
			#添加到战报中
			report[:round] = @round
			report[:action] = {:side=>@actionSide, :index=>actionOne[:index], :blood=>actionOne[:blood]}
			if not report[:receiver] 
				report[:receiver] = []
			end
			report[:receiver] << {:index=>receiveOne[:index], :bloodbefore=>oldBlood, :blood=>receiveOne[:blood]}
			if not @report[:battleproc][@round]
				@report[:battleproc][@round] = []
			end
			@report[:battleproc][@round] << report
		end
		# 战斗类型
		# @params
		# @return [Integer]
		def getBattleType
			@battleType
		end
	end #end class
end #end module