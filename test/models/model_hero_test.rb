require File.expand_path("../../test_helper",__FILE__)
require 'json'
class HeroTest < Minitest::Test
	def test_recurite
		player = Model::Player.register("kevin","image")[:player]
		hero  = Model::Hero.recuritHero(player,"normal")[:hero]
		heroid = hero[:heroId]
		heroFromRedis = JSON.parse(RedisClient.get(Const::Rediskeys.getHeroKey(heroid,player[:playerId])), {:symbolize_names => true})
		assert(heroFromRedis,"hero info got from the redis is not exist")
		assert_equal(heroFromRedis[:heroId],hero[:heroId])
		heroidlist = JSON.parse(RedisClient.get(Const::Rediskeys.getHeroListKey(player[:playerId])), {:symbolize_names => true})
		assert_equal(true, heroidlist.index(heroid) != nil)
		#recurite again
		retcode  = Model::Hero.recuritHero(player,"normal")[:retcode]
		assert_equal(Const::ErrorCode::HeroRecuritDimondNotEnough, retcode)
	end

	def test_register_main_hero
		player = Model::Player.register("kevin_main","image")[:player]
		hero  = Model::Hero.registerMainHero("11001",player)[:hero]
		heroid = hero[:heroId]
		heroFromRedis = JSON.parse(RedisClient.get(Const::Rediskeys.getHeroKey(heroid,player[:playerId])), {:symbolize_names => true})
		assert(heroFromRedis,"hero info got from the redis is not exist after register main hero")
		assert_equal(heroFromRedis[:heroId],hero[:heroId])
		heroidlist = JSON.parse(RedisClient.get(Const::Rediskeys.getBattleHeroListKey(player[:playerId])), {:symbolize_names => true})
		assert_equal(true, heroidlist.include?(heroid))
		myIdList = Array.new(8){Const::HeroLocked}
		myIdList[0] = heroid
		myIdList[1] = Const::HeroEmpty
		assert_equal(myIdList,heroidlist)
	end

	def test_get_battle_hero_list
		player = Model::Player.register("kevin_for_main_hero","image")[:player]
		hero  = Model::Hero.registerMainHero("11001",player)[:hero]
		heroList = Model::Hero.getBattleHeroList(player[:playerId])
		assert(heroList, "battle hero list is not exist ")
		assert_equal(8 ,heroList.length)
		p heroList.to_json
		assert_equal(hero[:heroId], heroList[0][:heroId])
		assert_equal(Const::HeroEmpty, heroList[1])
	end

	def test_replace_hero
		player = Model::Player.register("kevin_for_replace_hero","image")[:player]
		heroMain  = Model::Hero.registerMainHero("11001",player)[:hero]
		heroFree  = Model::Hero.recuritHero(player,"normal")[:hero]
		ret = Model::Hero.replaceHero(1, heroFree[:heroId], player)
		assert_equal(Const::ErrorCode::Ok, ret[:retcode])
		ret = Model::Hero.replaceHero(2, heroFree[:heroId], player)
		assert_equal(Const::ErrorCode::Fail, ret[:retcode])
		heroDao = HeroDao.new
		battleHeroIdList = heroDao.getBattleHeroIdList(player[:playerId])
		heroIdlist = heroDao.getHeroIdList(player[:playerId])
		assert_equal(true, battleHeroIdList.include?(heroFree[:heroId]))
		assert_equal(0,heroIdlist.length)
		#跟主将更换
		heroFree2 = Model::Hero.recuritHero(player,"advanced")[:hero]
		ret = Model::Hero.replaceHero(0, heroFree2[:heroId], player)
		assert_equal(Const::ErrorCode::Ok, ret[:retcode])
		heroIdlist = heroDao.getHeroIdList(player[:playerId])
		assert_equal(1, heroIdlist.length)
		assert_equal(true, heroIdlist.include?(heroMain[:heroId]))
	end

	def test_trans_hero
		player = Model::Player.register("kevin_for_trans_hero","image")[:player]
		heroMain  = Model::Hero.registerMainHero("11001",player)[:hero]
		heroFree  = Model::Hero.recuritHero(player,"normal")[:hero]
		commonDao = CommonDao.new
		heroDao = HeroDao.new
		freeHeroKey = Const::Rediskeys.getHeroKey(heroFree[:heroId],player[:playerId])
		heroFree[:level] = 4
		commonDao.update({freeHeroKey => heroFree})
		Model::Hero.transHero(heroMain[:heroId],heroFree[:heroId],"normal",player)
		heroIdlist = heroDao.getHeroIdList(player[:playerId])
		assert_equal(0,heroIdlist.length)
		assert_equal(nil,heroDao.get(heroFree[:heroId],player[:playerId]))
		heroMain = Model::Hero.getHero(heroMain[:heroId], player[:playerId])
		assert_equal(true, heroMain[:level] > 1)
	end

	def test_arrange_battle
		player = Model::Player.register("battle_arrange","image")[:player]
		heroMain  = Model::Hero.registerMainHero("11001",player)[:hero]
		heroDao = HeroDao.new
		heroFree  = Model::Hero.recuritHero(player,"normal")[:hero]
		#跟空闲位交换
		ret = Model::Hero.arrangeBattleHero(0, 1, player[:playerId])
		assert_equal(Const::ErrorCode::Ok,ret[:retcode])
		battleHeroIdList = heroDao.getBattleHeroIdList(player[:playerId])
		assert_equal(Const::HeroEmpty, battleHeroIdList[0])
		assert_equal(heroMain[:heroId], battleHeroIdList[1])
		#上阵英雄
		Model::Hero.replaceHero(0, heroFree[:heroId], player)
		battleHeroIdList = heroDao.getBattleHeroIdList(player[:playerId])
		assert_equal(heroFree[:heroId], battleHeroIdList[0])
		assert_equal(heroMain[:heroId], battleHeroIdList[1])
	end

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

	def test_advanced_hero
		player = Model::Player.register("advanced_hero","image")[:player]
		heroMain  = Model::Hero.registerMainHero("11001",player)[:hero]
		heroFree  = Model::Hero.recuritHero(player,"normal")[:hero]
		ret = Model::Hero.advancedHero(heroMain[:heroId], heroFree[:heroId], player[:playerId])
		assert_equal(Const::ErrorCode::Ok,ret[:retcode])
		advancedHeroMain = Model::Hero.getHero(heroMain[:heroId], player[:playerId])
		assert_equal(1, advancedHeroMain[:adlevel])
		assert_equal(true ,advancedHeroMain[:attack] > heroMain[:attack])
		assert_equal(true ,advancedHeroMain[:capacity] > heroMain[:capacity])
	end


	def test_pre_bringup_hero
		player = Model::Player.register("bringup_hero","image")[:player]
		heroMain  = Model::Hero.registerMainHero("11001",player)[:hero]
		ret = Model::Hero.preBringupBattleHero(heroMain[:heroId], player[:playerId], Const::HeroBringUpNormal)
		Model::Hero.preBringupBattleHero(heroMain[:heroId], player[:playerId], Const::HeroBringUpAdvancedTen)
	end

end