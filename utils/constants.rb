module Const
	#乐观锁重试次数
	RetryTimes = 3
	#战斗英雄空位
	HeroEmpty = 0
	#战斗锁住
	HeroLocked = -1
	#不选择英雄，默认上阵
	HeroBattleNoSelectIndex = -2
	#培养
	HeroBringUpNormal = 1
	#培养10次
	HeroBringUpNormalTen = 2
	#高级培养
	HeroBringUpAdvanced = 3
	#高级培养10次
	HeroBringUpAdvancedTen = 4
	#------------------道具类型
	#武器
	ItemTypeWeapon = 1
	#防具
	ItemTypeShield = 2
	#坐骑
	ItemTypeHorse = 3
	#兵法
	ItemTypeBook = 4
	#宝物
	ItemTypeProp = 5

	#------------------进阶结果 可通用
	#进阶成功
	BookAdvanceSuccess = "success"
	#进阶失败
	BookAdvanceFail = "fail"

	#------------------任务类型
	#战役
	TaskTypeBattle = "campaign"
	#武将
	TaskTypeHero = "hero"
	#装备数量
	TaskTypeEquip = "equip"
	#兵法数量
	TaskTypeBook = "book"
	#强化
	TaskTypeRefine = "refine"
	#情谊,命运
	TaskTypeShip = "skill"
	#竞技场
	TaskTypeArena = "arena"
	#竞技场连胜
	TaskTypeArenaWin = "arenawin"
	#培养
	TaskTypeTrain = "train"
	#通天塔相关
	TaskTypeTower = "tower"
	#towerstar
	TaskTypeTowerStar = "towerstar"
	#银矿
	TaskTypeSilver = "silver"
	#夺宝
	TaskTypeRob = "rob"
	#兵法进阶
	TaskTypeBookAdvance = "bookadvance"

	#--------任务状态
	#已完成
	StatusEnable = "enable"
	#未完成
	StatusDisable = "disable"

	#--------奖励类型
	#钻石
	RewardTypeDimond = "dimond"
	#银币
	RewardTypeSiliver = "siliver"
	#道具（武器防具坐骑兵法宝物）
	RewardTypeItem = "item"
	#武将类
	RewardTypeHero = "hero"
	#将魂
	RewardTypeSoul = "soul"
	#-------排序类型
	SortDesc = "desc"
	SortAsc = "asc"

	#战斗类型
	#征讨
	BattleTypePVE = 1
	#夺宝
	BattleTypeDuoBao = 2
	#国战
	BattleTypeCountry = 3
end