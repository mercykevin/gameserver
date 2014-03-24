post '/hero/recruit' do
	 
end

post '/hero/register' do
	requestParams = request[:req_parames]
	player = request[:player]
	templetHeroId = requestParams[:metaheroid]
	ret = Model::Hero.registerMainHero(templetHeroId, player)
	ret.to_json
end

