#!/usr/bin/env ruby
# Will rename every files given as argument in a smart case manner. Meaning
# that each word will be capitalize, except for common words like 'and' or
# 'with'

# Words that need not be capitalized
commonWords = ['with', 'and', 'of', 'the', 'a', 'or']
renames = []

ARGV.each do |file|
	# Skipping non-existing files
	next if !File.exists? file

	# Getting each part of the filename
	fullpath=File.expand_path(file)
	basename=File.basename(file).downcase
	dirname=File.dirname(fullpath)

	# Capitalizing it
	capitalized = basename.split(' ').each do |word|
		# We put common word downcase and every other word capitalized
		if commonWords.include? word.downcase
			word.downcase!
		else
			word.capitalize!
		end
	end.join(' ')

	hash = { :old => fullpath, :new => File.join(dirname, capitalized) }

	# Creating a list of renames to perform, directories being renamed last
	if File.directory? fullpath
		renames << hash
	else
		renames.unshift hash
	end
end

renames.each do |hash|
	next if !File.exists?(hash[:old])
	File.rename(hash[:old], hash[:new])
end
