module Model
	class ErrorCode
		#操作成功
		Ok = 1
		#操作失败
		Fail = 0
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
	end
end