post '/player/get' do
  RedisClient.set('mykey','hello world')
  world = ::RedisClient.get('mykey')
  #{world}\n"
end

post '/player/randname' do
	requestParams = request[:req_parames]
	randName = Model::Player.randomName(requestParams[:gender])
	{:name => randName}.to_json
end

post '/player/register' do
	name = request[:req_parames][:name]
	headimg = request[:req_parames][:headpic]
	#创建角色
	ret = Model::Player.register(name,headimg)
	player = ret[:player]
	GameLogger.debug("Controllers::Player./player/register:register retcode=#{ret[:retcode]}")
	if ret[:retcode] == Const::ErrorCode::Ok
		#设置登录状态
		Model::Player.setOnline(request[:game_session_id],player[:playerId])
	end
	ret.to_json
end

post '/player/listnotice' do
	noticeList = Model::Notice.getNoticeList
	noticeList.to_json
end
