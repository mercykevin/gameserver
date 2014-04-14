#任务列表
post '/task/list' do
	requestParams = request[:req_parames]
	player = request[:player]
	itemList = Model::Task.getTaskList(player[:playerId])
	itemList.to_json
end

#领取任务
post '/task/getaward' do 
	requestParams = request[:req_parames]
	player = request[:player]
	iid = requestParams[:iid]
	itemList = Model::Task.getTaskAward(player[:playerId] , iid)
	itemList.to_json
end
