module MetalDetectr
  class MetalArchives
    # Gets paginated result urls if needed,
    # gets the album urls to search from the paginated result urls if needed,
    # gets all the releases from the album urls if needed.
    def self.generate_releases
      if !CompletedStep.finished_fetching_releases?
        self.fetch_paginated_result_urls
        paginated_urls = self.urls_to_search
        self.fetch_album_urls(paginated_urls)
        self.complete_album_urls_fetch_if_finished!
        self.releases_from_urls
        self.complete_releases_from_urls_if_finished!
        # only do this when all the releases are collected
      else
        self.update_release_dates #unless CompletedStep.finished_fetching_releases?
        # self.reset_data
      end
    end

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
        ::Rails.logger.info "\nStarting search from: #{last_album_url.page}" if last_album_url.page < paginated_urls.length
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
            ::Rails.logger.info "\nMetalDetectr::MetalArchives#fetch_album_urls: timed out!"
            break
          end
          ::Rails.logger.info "\nCreating AlbumUrl from page #{paginated_url.page_number}"
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
        ::Rails.logger.info "\nMetalDetectr::MetalArchives: completed fetching album urls"
        CompletedStep.find_or_create_by_step(CompletedStep::AlbumUrlsCollected)
      end
    end

    # If last album url is a url of a release, it's already looked at all of them.
    def self.complete_releases_from_urls_if_finished!
      if !CompletedStep.finished_fetching_releases? && Release.exists?(:url => AlbumUrl.last.url)
        ::Rails.logger.info "\nMetalDetectr::MetalArchives: completed fetching releases"
        CompletedStep.find_or_create_by_step(CompletedStep::ReleasesCollected)
      end
    end

    # Searches through the remaining album urls and saves the new ones. If the site times-out,
    # mark where the search is for the next time.
    def self.releases_from_urls
      return unless CompletedStep.finished_fetching_album_urls?
      agent = ::MetalArchives::Agent.new

      self.albums_to_search.each do |album_url|
        album = agent.album_from_url(album_url.url)
        if album.nil? # timed out
          ::Rails.logger.info "\nMetalDetectr::MetalArchives#releases_from_urls: timed out!"
          SearchedRelease.save_for_later(album_url)
          break
        end
        ::Rails.logger.info "\nCreating release: #{album}"
        Release.create_from(album)
      end
    end

    def self.update_release_dates
      if CompletedStep.finished_fetching_releases? && !CompletedStep.finished_updating_releases_from_amazon?
        self.release_dates_to_search_from_amazon.each do |release|
          begin
            us_release_date = MetalDetectr::AmazonSearch.find_us_release_date(release)
            euro_release_date = MetalDetectr::AmazonSearch.find_euro_release_date(release)
          rescue Exception => e          
            Rails.logger.info "Error accessing amazon.com: #{e}"
            SearchedAmazonDateRelease.save_for_later(release)
            break
          end

          attributes_to_update = {}
          unless us_release_date.nil?
            Rails.logger.info "updating US release date from amazon.com for #{release.id} to: #{us_release_date.inspect}"
            #release.update_attribute(:us_date, us_release_date)
            attributes_to_update[:us_date] = us_release_date
          end

          unless euro_release_date.nil?
            Rails.logger.info "updating European release date from amazon.com for #{release.id} to: #{euro_release_date.inspect}"
            #release.update_attribute(:euro_date, euro_release_date)
            attributes_to_update[:euro_date] = euro_release_date
          end
          release.update_attributes(attributes_to_update)

          self.complete_release_dates_update_if_finished!(Release.last, release)
        end
      end
    end

    private

    # If we were previously searching albums, get all the album urls saved after and including
    # the previous one. Otherwise, get all the album urls.
    def self.albums_to_search
      album_to_search = SearchedRelease.last
      if album_to_search.present?
        AlbumUrl.where("id >= #{album_to_search.album_url_id}")
      else
        AlbumUrl.all
      end
    end

    # If we were previously searching release dates on amazon, get all the album urls saved after and including
    # the previous one. Otherwise, get all the album urls.
    def self.release_dates_to_search_from_amazon
      release_to_search = SearchedAmazonDateRelease.last
      if release_to_search.present?
        Release.where("id >= #{release_to_search.release_id}")
      else
        Release.all
      end
    end

    # Erase data used to generate releases for new search for metal-archives.com.
    def reset_metal_archives_data
      ::Rails.logger.info "\nCleaning up old data."
      AlbumUrl.destroy_all
      CompletedStep.destroy_all
      PaginatedSearchResultUrl.destroy_all
      SearchedRelease.destroy_all
      SearchedAmazonDateRelease.destroy_all
      ::Rails.logger.info "\nData reset."
    end

    # Marks the step of updating the album urls as complete when all the releases have
    # checked for updated release dates on Amazon.
    def self.complete_release_dates_update_if_finished!(last_release, current_release)
      if last_release.id == current_release.id
        ::Rails.logger.info "\nMetalDetectr::MetalArchives: completed updating release dates from Amazon"
        CompletedStep.find_or_create_by_step(CompletedStep::ReleasesUpdatedFromAmazon)
      end
    end
  end
end
