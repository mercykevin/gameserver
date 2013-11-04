require "json"
module Model
	class Notice
		def self.getNoticeList
			notice = ::RedisClient.get(::Model::RedisKeys.getNoticeListKey)
			JSON.parse(notice)
		end

		def self.createNotice(noticeType,title,content)

		end

		
	end
end