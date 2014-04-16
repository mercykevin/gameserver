module Const
	class ErrorCode
		#操作成功
		Ok = 1
		#操作失败
		Fail = 0

		#-------------------------------通用

		#银币不足
		SilverIsNotEnough = 10000
		#钻石不足，请充值
		DiamondIsNotEnough = 10010
		#已达最高级:兵法，装备.... (大部分，前端都会处理，比如按钮灰掉)
		LevelIsTheHighest = 10020
		#背包已满
		BackpackIsFull = 10030
		
		#-------------------------------

		#玩家信息不存在
		PlayerIsNotExist = 1000001
		#该角色名已被注册
		PlayerIsExistByName = 1000001
		#招募英雄失败，您的金币不够
		HeroRecuritShortOfGold = 9000001
		#招募英雄失败，超过最高上限
		HeroRecuritOutofLimit = 9000002
		#数据非法
		HeroRecuritTempleteHeroIsNotExist = 9000003
		#注册主英雄失败，已经有上阵的主英雄了
		HeroRegisterFailHeroExist = 9000004
		#英雄超过最大可招募数
		HeroRecuritLimitsUp = 9000005
		#现在还不能招募，待cd冷却
		HeroRecuritCDError = 9000006
		#钻石数不够，不能招募
		HeroRecuritDimondNotEnough = 9000007

		#---------------------------------道具通用
		#装备不存在
		EquipmentIsNotExist = 2000000
		#兵法不存在
		BookIsNotExist = 2000010
		#背包格子已经到了上限
		PackCellAlreadyIsMaxCount = 200020

		#装备等级不能超过君主等级三倍
		EquipStrengthenLevelCannotOverPlayer = 200025

		#---------------------------------进阶
		#请选择要进阶的兵法
		BookAdvancedNoTargetBook = 2000100
		#请选择被祭祀兵法
		BookAdvancedNoBooksChoosed = 2000101
		#兵法已上阵,不能祭祀
		BookHasToBattle = 2000102
		#自有兵法不能祭祀
		BookIsHeroSelf = 2000103

		#----------------------------任务
		#任务已领取
		TaskIsAlreadyGetAward = 2000110
		#任务未完成
		TaskIsNotBeComplated = 2000111

	end
end