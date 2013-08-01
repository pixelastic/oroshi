# encoding : utf-8
# Usage :
# subtitle-import-synchro file.srt synched.srt
# Given two srt files, will use the synch of synched.srt with the text of 
# file.srt.

class SubtitleImportSynchro
	def initialize(*args)
		if args.size != 2
			puts "Usage : "
			puts "$ subtitle-import-synchro input.srt synched.srt"
			exit
		end

		@input_file = File.expand_path(args[0])
		@synched_file = File.expand_path(args[1])
		raise Errno::ENOENT unless File.exists?(@input_file)
		raise Errno::ENOENT unless File.exists?(@synched_file)

		@input   = File.readlines(@input_file)
		@synched = File.readlines(@synched_file)
	end

	def run
		content = []
		index = 0
		@input.each do |value|
			if value[' --> ']
				content << @synched[index]
			else
				content << value
			end
			index+=1
		end

		new_file = File.basename(@input_file, '.srt') + '.synched.srt'
		File.open(new_file, 'w') do |file|
			file.write(content.join(''))
		end
	end
end
