post '/player/get' do
  ::RedisClient.set('mykey','hello world')
  world = ::RedisClient.get('mykey')
  #{world}\n"
end

post '/player/randname' do
	randName = Model::User.randomName
	randName.to_json
end

post '/player/register' do
	name = request[:req_parames][:name]
	ret = Model::User.register(name)
	ret.to_json
end

post '/player/listnotice' do
	noticeList = Model::Notice.getNoticeList
	noticeList.to_json
end
