module Model
	class MetaData
		#init meta data holders
		# @param [Array,Array] names csv file second row name in English, values rows
		# @return
		def initialize(names,values)
			@attributes  = {}
			if names.length != values.length
				raise StandardError "csv meta data name field length not equals value row length"
			end
			names.each_with_index do |name,i|
				@attributes[name] = values[i]
			end
        end
        # method missing
        def method_missing(name, *args)
        	attribute = name.to_s
        	if attribute =~ /=$/
        		@attributes[attribute.chop] = args[0]
        	else
        		@attributes[attribute]
        	end
        end

        def getAttr(name)
        	@attributes[name]
        end
	end
end