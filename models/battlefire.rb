module Model
	class BattleFire
		# 构造函数
		# @params[Array,Array,Integer,String] 进攻方，防守方 
		def initialize(attack, attackPlayer, defend, defendPlayer, battleType, battleId)
			@attack = attack
			@attackPlayer = attackPlayer
			@defend = defend
			@defendPlayer = defendPlayer
			@battleType = battleType
			@battleId = battleId
			#战斗回合
			@round = 1
			#当前行动方,是否是进功方进攻，如果是false的话，就是防守方行动，打
			@actionSide = true
			@attackOne = nil
			@defendOne = nil
		end
		# 构造pve的battlefire对象
		# @params[Integer,String]
		def self.createPVE(playerId, battleId)
			battleDao = BattleDao.new
			playerDao = PlayerDao.new
			attack = battleDao.generatePlayerBattle(playerId)
			defend = battleDao.generatePVENPC(battleId)
			player = playerDao.getPlayer(playerId)
			new(attack, playerId, defend, "NPC", Const::BattleTypePVE, battleId)
		end
		# 构造pvp的battlefire对象
		# @构造pvp的战役对象
		def self.createPVP(attackPlayerId, defendPlayerId, battleType)
			battleDao = BattleDao.new
			playerDao = PlayerDao.new
			attack = battleDao.generatePlayerBattle(attackPlayerId)
			attackPlayer = playerDao.getPlayer(attackPlayerId)
			defend = battleDao.generatePlayerBattle(defendPlayerId)
			defendPlayer = playerDao.getPlayer(defendPlayerId)
			new(attack, attackPlayer, defend, defendPlayer, battleType, nil)
		end
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
				#行动方轮换
				@actionSide = not @actionSide
			end
		end
		# 战斗计算

		# 处理战斗奖励
		def reward()
		end
		#获取战报
		def getReport()
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
		#处理行动方的战斗单元
		def pickActionOne(actions)
			actions.each_pair do |k,v|
				#没有行动过
				if not v[:isAction]
					return k
				end
			end 
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
					return receivers[:actionIndex - 1]
				else
					if receivers[actionIndex]
						return receivers[actionIndex]
					end
				end
			end
			#对应的同排都没的话，开始往外扩散找，找离自己最近的
			#先往后找
			findBack = nil
			

		end
		#战斗计算
		def calculateBattle(actionOne,receiveOne)
			a = 200 * 0.06 * actionOne[:level] * 0.25
			b = 200 * 0.06 * receiveOne[:level] * 0.1
			k = 0
			hurt =  actionOne[:attack] * 5 + rand(a) - (receiveOne[:defend] * 2.5 + rand(b)) + k
			receiveOne[:blood] = [0, receiveOne[:blood] - hurt].max
		end
	end
end