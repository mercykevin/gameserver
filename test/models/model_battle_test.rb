require File.expand_path("../../test_helper",__FILE__)
require 'json'
class BattleTest < Minitest::Test
	def test_getSubBattleList
		Model::Battle.getSubBattleList(100001,1)
	end

	def test_pve
		player = Model::Player.register("kevin_main","image")[:player]
		hero  = Model::Hero.registerMainHero("300001",player)[:hero]
		#跳战役打，不能成功
		ret = Model::Battle.pve(101003,player[:playerId])
		assert_equal(Const::ErrorCode::Fail,ret[:retcode])
		#打第一个战役
		ret = Model::Battle.pve(101001,player[:playerId])
		assert_equal(Const::ErrorCode::Ok,ret[:retcode])
		battleDao = BattleDao.new
		metaDao = MetaDao.instance
		#取战役常量
		metaBattleData = metaDao.getSubBattleMetaData(101001)
		playerSubBattleMap = battleDao.getSubBattleInfoMap(metaBattleData.battlefirstID, player[:playerId])
		battleInfo = playerSubBattleMap[101001.to_s.to_sym]
		assert_equal(false,battleInfo[:win])
		#再打一次
		ret = Model::Battle.pve(101001,player[:playerId])
		assert_equal(Const::ErrorCode::Ok,ret[:retcode])
		playerSubBattleMap = battleDao.getSubBattleInfoMap(metaBattleData.battlefirstID, player[:playerId])
		battleInfo = playerSubBattleMap[101001.to_s.to_sym]
		assert_equal(true,battleInfo[:win])
	end
end