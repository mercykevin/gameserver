require "Player.pb"
class PlayerDao
  def getPlayer(playerId)
    key = "player:"+playerId
    playerContent = $redis.get(key)
    if playerContent
      player = Com::Mobile::Sanguo::Player.parse(playerContent)
      return player
    end
  end
  
  def setPlayer(player,playerId)
    key = "player:"+playerId
    open("player_msg", "wb") do |f|
      player.serialize(f)
    end
    playerSe = player.serialize_to_string
    return playerSe
  end
end