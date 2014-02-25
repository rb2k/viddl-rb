class UrlResolver

  PLAYLIST_FEED = "http://gdata.youtube.com/feeds/api/playlists/%s?&max-results=50&v=2"
  USER_FEED     = "http://gdata.youtube.com/feeds/api/users/%s/uploads?&max-results=50&v=2"

  def get_all_urls(url, filter = nil)
    @filter = filter

    if url.include?("view_play_list") || url.include?("playlist?list=")     # if playlist URL
      parse_playlist(url)
    elsif username = url[/\/(?:user|channel)\/([\w\d]+)(?:\/|$)/, 1]        # if user/channel URL
      parse_user(username)
    else                                                                    # if neither return nil
      [url]
    end
  end

  private

  def parse_playlist(url)
    #http://www.youtube.com/view_play_list?p=F96B063007B44E1E&search_query=welt+auf+schwäbisch
    #http://www.youtube.com/watch?v=9WEP5nCxkEY&videos=jKY836_WMhE&playnext_from=TL&playnext=1
    #http://www.youtube.com/watch?v=Tk78sr5JMIU&videos=jKY836_WMhE

    playlist_ID = url[/(?:list=PL|p=|list=)(.+?)(?:&|\/|$)/, 1]
    Youtube.notify "Playlist ID: #{playlist_ID}"
    feed_url = PLAYLIST_FEED % playlist_ID
    url_array = get_video_urls(feed_url)
    Youtube.notify "#{url_array.size} links found!"
    url_array
  end

  def parse_user(username)
    Youtube.notify "User: #{username}"
    feed_url = USER_FEED % username
    url_array = get_video_urls(feed_url)
    Youtube.notify "#{url_array.size} links found!"
    url_array
  end

  #get all videos and return their urls in an array
  def get_video_urls(feed_url)
    Youtube.notify "Retrieving videos..."
    urls_titles = {}
    result_feed = Nokogiri::XML(open(feed_url))
    urls_titles.merge!(grab_urls_and_titles(result_feed))

    #as long as the feed has a next link we follow it and add the resulting video urls
    loop do
      next_link = result_feed.search("//feed/link[@rel='next']").first
      break if next_link.nil?
      result_feed = Nokogiri::HTML(open(next_link["href"]))
      urls_titles.merge!(grab_urls_and_titles(result_feed))
    end

    filter_urls(urls_titles)
  end

  #extract all video urls and their titles from a feed and return in a hash
  def grab_urls_and_titles(feed)
    feed.remove_namespaces!  #so that we can get to the titles easily
    urls   = feed.search("//entry/link[@rel='alternate']").map { |link| link["href"] }
    titles = feed.search("//entry/group/title").map { |title| title.text }
    Hash[urls.zip(titles)]    #hash like this: url => title
  end

  #returns only the urls that match the --filter argument regex (if present)
  def filter_urls(url_hash)
    if @filter
      Youtube.notify "Using filter: #{@filter}"
      filtered = url_hash.select { |url, title| title =~ @filter }
      filtered.keys
    else
      url_hash.keys
    end
  end
end
