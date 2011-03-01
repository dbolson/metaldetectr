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
        #puts "starting search from: #{last_album_url.page}"
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
          if album_urls.nil?  # timed-out
            break
          end
          album_urls.each do |album_url|
            AlbumUrl.find_or_create_by_page_and_url(
              :page => paginated_urls.find_index(paginated_url) + 1,
              :url => album_url
            )
          end
        end
      end
    end

    # Marks the step of fetching the album urls as complete when all the paginated urls have
    # returned the urls for the albums on their pages.
    def self.complete_album_urls_fetch_if_finished!
      unless CompletedStep.finished_fetching_album_urls?
        agent = ::MetalArchives::Agent.new
        if agent.total_albums == AlbumUrl.count
          CompletedStep.find_or_create_by_step(CompletedStep::AlbumUrlsCollected)
        end
      end
    end

    def self.albums_from_urls
      unless CompletedStep.finished_fetching_album_urls?
        agent = ::MetalArchives::Agent.new

        self.albums_to_search.each do |album_url|
          album = agent.album_from_url(album_url.url)
          if album.nil?
            self.search_album_later!(album_url) # TODO: rename model?
            break # timed-out
          end
          self.create_release(album)
        end
        #if all albums are collected, mark as complete
      end
    end

    def self.create_release(album)
      Release.find_or_create_by_name_and_band_and_url(
        :name => album[:album],
        :band => album[:band],
        :format => album[:release_type],
        :label => album[:label],
        :url => album[:url],
        :us_date => album[:release_date]
      )
    end

    private

    def self.albums_to_search
      album_to_search = SearchedAlbum.last
      if album_to_search.present?
        AlbumUrl.where("id >= #{album_to_search.id}")
      else
        AlbumUrl.all
      end
    end

    # def self.search_album_later!(url)
    # end
  end
end
