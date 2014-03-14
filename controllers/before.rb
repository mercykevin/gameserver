helpers do
	def parseReq(request)
		if request.body
			request.body.rewind
			bodyData = request.body.read
			if bodyData and ! bodyData.empty? and bodyData !=''
				request[:req_parames] = JSON.parse bodyData
			end
		end
	end
end

before do
	response['X-UA-Compatible'] = "IE=edge,chrome=1"
	if not request.cookies["game_session_id"]
		session_id = SecureRandom.hex
		response.set_cookie("game_session_id", :value => session_id)
	end
	parseReq(request)
end



