require File.expand_path("../../test_helper",__FILE__)
require 'json'
class HeroTest < Minitest::Test


	def test_arrange_all
		player = Model::Player.register("battle_arrange_all","image")[:player]
		heroMain  = Model::Hero.registerMainHero("11001",player)[:hero]
		heroDao = HeroDao.new
		heroFree  = Model::Hero.recuritHero(player,"normal")[:hero]
		battleHeroIdList = heroDao.getBattleHeroIdList(player[:playerId])
		tempId = battleHeroIdList[0]
		battleHeroIdList[0] = battleHeroIdList[1]
		battleHeroIdList[1] = tempId
		ret = Model::Hero.arrangeAllBattleHero(battleHeroIdList,player[:playerId])
		assert_equal(Const::ErrorCode::Ok,ret[:retcode])
		battleHeroIdList = heroDao.getBattleHeroIdList(player[:playerId])
		battleHeroIdList[0] = heroMain[:heroId]
		battleHeroIdList[1] = heroMain[:heroId]
		ret = Model::Hero.arrangeAllBattleHero(battleHeroIdList,player[:playerId])
		assert_equal(Const::ErrorCode::Fail,ret[:retcode])
	end

end