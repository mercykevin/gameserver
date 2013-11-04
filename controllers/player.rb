get '/player/get' do
  ::RedisClient.set('mykey','hello world')
  world = ::RedisClient.get('mykey')
  #{world}\n"
end

post '/player/randname' do

end

post '/player/register' do
	
end

post '/player/listnotice' do
end

post '/player/notice' do
	
end