get '/user/get' do
  ::RedisClient.set('mykey','hello world')
  world = ::RedisClient.get('mykey')
  #{world}\n"
end

get '/usr/randomname' do
	
end