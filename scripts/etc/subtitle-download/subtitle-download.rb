# encoding : utf-8
require 'curb'
require 'nokogiri'

# Download subtitles from sous-titres.eu
class SubtitleDownload
  def initialize(*args)
    @website_url = 'https://www.sous-titres.eu/'
    @name = args[0]
    @season = args[1]
    @episode = args[2]
    @movie = !args[1]
  end

  def page_url
    url = @website_url
    if @movie
      url += 'movies/'
    else
      url += 'series/'
    end
    url += @name.gsub(' ', '_').downcase
    url + '.html'
  end

  def page_available(url)
    output = `wget --spider -O /dev/null -q '#{url}' && echo 1 || echo 0`
    output.strip!
    return true if output == '1'
    false
  end

  def get_links_from_url(url)
    body = Curl.get(url).body_str
    doc = Nokogiri::HTML(body)
    all_links = doc.css('a.subList')
    # keeping only french links
    links = []
    all_links.each do |link|
      links << link['href'] if link.css('span.lang img[title=fr]').length > 0
    end
    links
  end

  def get_matching_link_from_list(list)
    list.each do |link|
      basename = File.basename(link)
      if @movie
        return @website_url + 'movies/' + link if basename.match(/(#{@name})/)
      else
        if basename.match(/(S?)(0?)(#{@season})(E|x)(0?)(#{@episode})([^0-9])/)
          return @website_url + 'series/' + link
        end
      end
    end
    nil
  end

  def run
    page_url = page_url
    unless page_available(page_url)
      puts "Unable to access #{page_url}"
      return
    end

    links = get_links_from_url(page_url)
    matching_link = get_matching_link_from_list(links)

    unless matching_link
      puts 'Unable to find subtitle'
      return
    end
    `wget -c '#{matching_link}'`
  end
end
