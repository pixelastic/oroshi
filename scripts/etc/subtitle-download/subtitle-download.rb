# encoding : utf-8
require 'curb'
require "nokogiri"


class SubtitleDownload

  def initialize(*args)
    @website_url = 'https://www.sous-titres.eu/'
    @name = args[0]
    @season = args[1]
    @episode = args[2]
    @is_movie = !args[1]
  end

  def get_page_url
    url = @website_url
    if @is_movie
      url = url + 'movies/'
    else
      url = url + 'series/'
    end
    url = url + @name.gsub(' ', '_').downcase
    url = url + '.html'
  end

  def is_page_available(url)
    output = %x[wget --spider -O /dev/null -q '#{url}' && echo 1 || echo 0]
    output.strip!
    return true if output == '1'
    return false
  end

  def get_links_from_url(url)
    body = Curl.get(url).body_str
    doc = Nokogiri::HTML(body)
    all_links = doc.css('a.subList')
    # keeping only french links
    links = []
    all_links.each do |link|
      if link.css('span.lang img[title=fr]').length > 0
        links << link['href']
      end
    end
    return links
  end

  def get_matching_link_from_list(list)
    list.each do |link|
      basename = File.basename(link)
      if @is_movie
        if basename.match(/(#{@name})/)
          return @website_url+ 'movies/' + link
        end
      else
        if basename.match(/(S?)(0?)(#{@season})(E|x)(0?)(#{@episode})([^0-9])/)
          return @website_url+ 'series/' + link
        end
      end
    end
    return nil
  end

  def run
    page_url = get_page_url
    unless is_page_available(page_url)
      puts "Unable to access #{page_url}"
      return
    end

    links = get_links_from_url(page_url)
    matching_link = get_matching_link_from_list(links)

    if !matching_link
      puts "Unable to find subtitle"
      return
    end
    %x[wget -c '#{matching_link}']
  end

end
