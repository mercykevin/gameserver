require 'json'
require "minitest/autorun"
class JsonTest < Minitest::Test

	def test_to_json
		player = {}
		player[:playerId] = 1
		player[:playerName] = "kevin"
		jsonValue = player.to_json
		player = JSON.parse(jsonValue)
		assert_equal("kevin",player[:playerName.to_s])
	end

	def test_rand
		
	end

	def test_array
		b = ["kevin1","kevin2","kevin3"]
		assert_equal(3,b.length)
		assert_equal("kevin1",b[0])
		b.delete_at(0)
		assert_equal("kevin2",b[0])
		assert_equal(2,b.length)
	end

	def test_ruby
		if not false
			puts "it's true"
		end
		if ! false
			puts "it's true too"
		end
	end
end
