namespace :app do
  namespace :metal_archives do
    desc "Fetch the paginated result urls for a search from metal-archives.com"
    task :fetch_paginated_result_urls => :environment do
      agent = MetalArchives::Agent.new

      if PaginatedSearchResultUrl.count == 0
        agent.paginated_result_urls.each do |paginated_result|
          PaginatedSearchResultUrl.find_or_create_by_url(paginated_result)
        end
      end
      paginated_urls = PaginatedSearchResultUrl.all

      last_album_url = AlbumUrl.last
      if last_album_url.nil?
        # start search at beginning
        urls_to_search = paginated_urls
      else
        # start search from last page
        urls_to_search = paginated_urls.slice(last_album_url.page, paginated_urls.length)
      end

      if CompletedStep.find_by_step(CompletedStep::AlbumUrlsCollected).nil?
        print 'fetching album urls'
        urls_to_search.each do |paginated_url|
          album_urls = agent.album_urls(paginated_url.url)
          if album_urls.nil?  # timed-out
            break
          else
            album_urls.each do |album_url|
              print '.'
              AlbumUrl.find_or_create_by_page_and_url(:page => paginated_urls.find_index(paginated_url) + 1, :url => album_url)
            end
          end
        end
        print "\n"

        url_count = AlbumUrl.count
        CompletedStep.find_or_create_by_step(CompletedStep::AlbumUrlsCollected) if agent.total_albums == url_count

        puts "found #{url_count} urls"
      end
    end

    desc "Fetch the album urls from a paginated search result url from metal-archives.com"
    task :fetch_album_urls => [:environment, :fetch_paginated_result_urls] do
    end

    desc "Fetch the albums from the paginated search urls from metal-archives.com"
    task :fetch_albums => [:environment, :fetch_album_urls] do
    end
  end
end
