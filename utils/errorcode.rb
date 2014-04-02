module Const
	class ErrorCode
		#操作成功
		Ok = 1
		#操作失败
		Fail = 0

		#非法的参数
		IllegeParam = 100

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



	end
end