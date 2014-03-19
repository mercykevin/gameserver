require File.expand_path("../../test_helper",__FILE__)
require 'json'
class HeroTest < Test::Unit::TestCase
	def test_recurite
		player = Model::Player.register("kevin")[:player]
		hero  = Model::Hero.recuritHero("11001",player,"normal")[:hero]
		heroid = hero[:heroId]
		heroFromRedis = JSON.parse(RedisClient.get(Const::Rediskeys.getHeroKey(heroid,player[:playerId])), {:symbolize_names => true})
		assert_not_nil(heroFromRedis,"hero info got from the redis is not exist")
		assert_equal(heroFromRedis[:heroId],hero[:heroId])
		heroidlist = JSON.parse(RedisClient.get(Const::Rediskeys.getHeroListKey(player[:playerId])), {:symbolize_names => true})
		assert_equal(true, heroidlist.index(heroid) != nil)
	end

	def test_register_main_hero
		player = Model::Player.register("kevin_main")[:player]
		hero  = Model::Hero.registerMainHero("11001",player)[:hero]
		heroid = hero[:heroId]
		heroFromRedis = JSON.parse(RedisClient.get(Const::Rediskeys.getHeroKey(heroid,player[:playerId])), {:symbolize_names => true})
		assert_not_nil(heroFromRedis,"hero info got from the redis is not exist after register main hero")
		assert_equal(heroFromRedis[:heroId],hero[:heroId])
		heroidlist = JSON.parse(RedisClient.get(Const::Rediskeys.getBattleHeroListKey(player[:playerId])), {:symbolize_names => true})
		assert_equal(true, heroidlist.index(heroid) != nil)
	end

	def test_get_battle_hero_list
		player = Model::Player.register("kevin_for_main_hero")[:player]
		hero  = Model::Hero.registerMainHero("11001",player)[:hero]
		heroList = Model::Hero.getBattleHeroList(player[:playerId])
		assert_not_nil(heroList, "battle hero list is not exist ")
		assert_equal(1 ,heroList.length)
		assert_equal(hero[:heroId], heroList[0][:heroId])
	end
end