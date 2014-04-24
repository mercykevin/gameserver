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

#	def record_memory_before
#		if File.exist?("/proc/#{Process.pid}/status")
#			process_status = File.open("/proc/#{Process.pid}/status")
#			13.times { process_status.gets }
#			@rss_before_action = process_status.gets.split[1].to_i
#			process_status.close
#		end
#	end
#
#	def record_memory_end
#		if File.exist?("/proc/#{Process.pid}/status")
#		    process_status = File.open("/proc/#{Process.pid}/status")  
#		    13.times { process_status.gets }  
#		    rss_after_action = process_status.gets.split[1].to_i  
#		    process_status.close  
#		    MemLogger.info("CONSUME MEMORY: #{rss_after_action - @rss_before_action} \  
#		KB\tNow: #{rss_after_action} KB\t#{request.url}")
#		end  
#	end  
end

before do
	#记录内存开始之前的数据
#	record_memory_before
	#
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

#after do
#	#记录请求结束时的内存的数据
#	record_memory_end
#end



