# encoding : utf-8
require 'open-uri'
require "fileutils"
require "shellwords"
require 'uri'
require "nokogiri"
# Given a Encode Explorer url, will download files in a given directory


class TransmissionDownload
	# Custom exceptions
	class Error < StandardError; end
	class ArgumentError < Error; end

	def initialize(*args)
		unless args.size > 0
			raise TransmissionDownload::ArgumentError, "You need to specify the url to download", ""
		end
		
		@url = authenticate_url(args[0])
		@base_url = get_base_url(@url)

		@tmp_html = File.expand_path('./tmp.html')
		@tmp_txt = File.expand_path('./tmp.txt')
	end

	# Update url with matching username/password if found
	def authenticate_url(url)
		uri = URI(url)
		host = uri.host

		# Finding a file wth credentials
		credential_files = File.expand_path(File.join('~/.oroshi/private/config/kingdoms', host))
		unless File.exists?(credential_files)
			return url
		end

		uri.user, uri.password = File.read(credential_files).chomp.split(':')
		return uri.to_s
	end

	# Get the base url http://domain.com/dirs
	def get_base_url(url)
		uri = URI(url)
		return uri.to_s.gsub('?'+uri.query, '')
	end

	# Download the target file as html
	def download_html_file
		puts "Downloading html page"
		wget_options = [
			'wget',
			'--continue',
			"'#{@url}'",
			"-O #{@tmp_html.shellescape}",
			'--quiet'
		]
		%x[#{wget_options.join(' ')}]
	end

	# Get a txt list file of all relevant links from an html file
	def get_list_file
		download_html_file
		doc = Nokogiri::HTML(File.new(@tmp_html))

		list = []
		# Parsing each link to find the relevant one
		doc.css('table.table td.name a.file').each do |link|
			list << {
				'name' => link.text,
				'url' => link['href']
			}
		end
		return list
	end


	def run
		get_list_file.each do |file|
			wget_options = [
				'wget',
				'--continue',
				"'#{@base_url}#{file['url']}'"
			]
			%x[#{wget_options.join(' ')}]
		end

		clean_up
	end

	def clean_up
		FileUtils.rm_f(@tmp_html)
		FileUtils.rm_f(@tmp_txt)
	end

end


