get '/game_area/list'  do
	areaList = Model::GameArea.getGameAreas
	areaList.to_json
end