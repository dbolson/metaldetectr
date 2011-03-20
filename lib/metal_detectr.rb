module MetalDetectr
  class MetalArchives
    # If there are no saved paginated result urls, fetch and save them from metal-archives.com.
    def self.fetch_paginated_result_urls
      if PaginatedSearchResultUrl.count == 0
        agent = ::MetalArchives::Agent.new
        agent.paginated_result_urls.each do |paginated_result|
          PaginatedSearchResultUrl.create(:url => paginated_result)
        end
      end
    end

    # Finds the saved paginated urls to search albums on.
    def self.urls_to_search
      paginated_urls = PaginatedSearchResultUrl.all

      last_album_url = AlbumUrl.last
      if last_album_url.nil? # start search at beginning
        paginated_urls
      else # start search from last page
        puts "Starting search from: #{last_album_url.page}"
        paginated_urls.slice(last_album_url.page, paginated_urls.length)
      end
    end

    # Fetches the album urls from the paginated urls if we haven't already found all of them.
    # We can't assume that the search will work for all the urls as the site will occasionally
    # time-out. If that happens, we'll have to try again the next time. Once all the album urls
    # are saved, we'll mark this step as completed and not search for them again.
    def self.fetch_album_urls(paginated_urls)
      unless CompletedStep.finished_fetching_album_urls?
        agent = ::MetalArchives::Agent.new

        paginated_urls.each do |paginated_url|
          album_urls = agent.album_urls(paginated_url.url)
          if album_urls.nil?  # timed out
            puts "MetalDetectr::MetalArchives#fetch_album_urls: timed out!"
            break
          end
          puts "Creating AlbumUrl from page #{paginated_url.page_number}"
          album_urls.each do |album_url|
            AlbumUrl.find_or_create_by_page_and_url(
              :page => paginated_url.page_number,
              :url => album_url
            )
          end
        end
      end
    end

    # Marks the step of fetching the album urls as complete when all the paginated urls have
    # returned the urls for the albums on their pages.
    def self.complete_album_urls_fetch_if_finished!
      return if CompletedStep.finished_fetching_album_urls?
      agent = ::MetalArchives::Agent.new
      if agent.total_albums == AlbumUrl.count
        puts "MetalDetectr::MetalArchives: completed fetching album urls"
        CompletedStep.find_or_create_by_step(CompletedStep::AlbumUrlsCollected)
      end
    end

    # If last album url is a url of a release, it's already looked at all of them.
    def self.complete_releases_from_urls_if_finished!
      if !CompletedStep.finished_fetching_releases? && Release.exists?(:url => AlbumUrl.last.url)
        puts "MetalDetectr::MetalArchives: completed fetching releases"
        CompletedStep.find_or_create_by_step(CompletedStep::ReleasesCollected)
      end
    end

    # Searches through the remaining album urls and saves the new ones. If the site times-out,
    # mark where the search is for the next time.
    def self.releases_from_urls
      return unless CompletedStep.finished_fetching_album_urls?
      agent = ::MetalArchives::Agent.new

      puts "Searching..."
      self.albums_to_search.each do |album_url|
        puts "Album_url: #{album_url.id}"
        album = agent.album_from_url(album_url.url)
        if album.nil? # timed out
          puts "MetalDetectr::MetalArchives#releases_from_urls: timed out!"
          SearchedAlbum.save_for_later(album_url)
          break
        end
        puts "Creating release: #{album}"
        Release.create_from(album)
      end
    end

    private

    # If we were previously searching albums, get all the album urls saved after and including
    # the previous one. Otherwise, get all the album urls.
    def self.albums_to_search
      album_to_search = SearchedAlbum.last
      if album_to_search.present?
        AlbumUrl.where("id >= #{album_to_search.album_url_id}")
      else
        AlbumUrl.all
      end
    end
  end
end
