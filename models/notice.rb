require "json"
module Model
	class Notice
		def self.getNoticeList
			notice = ::RedisClient.get(::Const::Rediskeys.getNoticeListKey)
			JSON.parse(notice)
		end

		def self.createNotice(noticeType,title,content)
			notice = ::RedisClient.get(::Const::Rediskeys.getNoticeListKey)
			noticeList = []
			if ! notice
				noticeList = JSON.parse(notice)
			end
			noticeItem = {}
			noticeItem[:noticeType] = noticeType
			noticeItem[:title] = title
			noticeItem[:content] = content
			noticeList << noticeItem
			::RedisClient.set(::Const::Rediskeys.getNoticeListKey,noticeList.to_json)
		end
	end
end