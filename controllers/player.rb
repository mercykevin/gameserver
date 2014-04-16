#获取角色信息
post '/player/get' do
	player = Model::Player.getBySession(request[:game_session_id])
	player.to_json
end

#随机角色名称
post '/player/randname' do
	requestParams = request[:req_parames]
	randName = Model::Player.randomName(requestParams[:gender])
	{:name => randName}.to_json
end

#注册角色
post '/player/register' do
	name = request[:req_parames][:name]
	headimg = request[:req_parames][:headpic]
	#创建角色
	ret = Model::Player.register(name,headimg)
	player = ret[:player]
	#输出日志
	GameLogger.debug("Controllers::Player./player/register:register retcode=#{ret[:retcode]}")
	if ret[:retcode] == Const::ErrorCode::Ok
		#设置登录状态
		Model::Player.setOnline(request[:game_session_id],player[:playerId])
		#TODO need remove later,add test item data
		Model::Item.addItem4Test(player[:playerId])
	end
	ret.to_json
end

post '/player/listnotice' do
	noticeList = Model::Notice.getNoticeList
	noticeList.to_json
end

