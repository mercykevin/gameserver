helpers do
	def parseReq(request)
		if request.body
			request.body.rewind
			bodyData = request.body.read
			if bodyData and ! bodyData.empty? and bodyData !=''
				#json解析出来的Hash key是symbols
				request[:req_parames] = JSON.parse(bodyData, {:symbolize_names => true})
			end
		end
	end
end

before do
	response['X-UA-Compatible'] = "IE=edge,chrome=1"
	session_id = cookies[:game_session_id]
	if not session_id
		session_id = SecureRandom.hex
		response.set_cookie("game_session_id", { :value => session_id,
                      :path => "/" })
		logger << "before do:cookie is not exist so genearte cookie:#{session_id} \n"
	end
	request[:game_session_id] = session_id
	player = Model::Player.getBySession(session_id)
	request[:player] = player
	logger << "before do:session_id = #{session_id},path_info = #{request.path_info} \n"
	parseReq(request)
end



