#require 'amazon_search'

module MetalDetectr
  class MetalArchives
    def self.generate_releases

      if CompletedStep.finished_fetching_releases?
        # only do this when all the releases are collected
        if CompletedStep.finished_updating_releases_from_amazon?
          ::Rails.logger.info "\n\nResetting data"
          reset_metal_archives_data
        else
          ::Rails.logger.info "\n\nUpdating dates from Amazon"
          self.update_release_dates_from_amazon
        end
      else
        agent = ::MetalArchives::Agent.new
        agent.paginated_albums.each_with_index do |album_page, index|
          album_page.each do |album|
            if album[0].match(::MetalArchives::Agent::NO_BAND_REGEXP).nil?
              Release.create(
                :name => agent.album_url(album),
                :band => agent.band_name(album),
                :format => agent.release_type(album),
                #:label => 
                :url => agent.album_url(album),
                :country => agent.country(album),
                :us_date => agent.release_date(album)
              )
            end
            CompletedStep.find_or_create_by_step(CompletedStep::ReleasesCollected)
          end
        end

        self.complete_releases_if_finished!
        # only do this when all the releases are collected
        #if CompletedStep.finished_fetching_releases? && !CompletedStep.finished_updating_releases_from_amazon?
        #  self.update_release_dates_from_amazon
        #end
      end
    end

    private

    # Searches amazon.com and its European sites to update the US and EUro release dates for each
    # release because we know the release is available at least on amazon's site at this time and isn't
    # bad data because of user error from metal-archives.com.
    def self.update_release_dates_from_amazon
      self.release_dates_to_search_from_amazon.each do |release|
        ::Rails.logger.info "Checking Amazon for release #{release.id}."
        begin
          us_release_date = MetalDetectr::AmazonSearch.find_us_release_date(release)
          euro_release_date = MetalDetectr::AmazonSearch.find_euro_release_date(release)
        rescue Exception => e          
          ::Rails.logger.info "Error accessing amazon.com: #{e}"
          SearchedAmazonDateRelease.save_for_later(release)
          break
        end

        attributes_to_update = {}
        unless us_release_date.nil?
          Rails.logger.info "updating US release date from amazon.com for #{release.id} to: #{us_release_date.inspect}"
          attributes_to_update[:us_date] = us_release_date
        end

        unless euro_release_date.nil?
          Rails.logger.info "updating European release date from amazon.com for #{release.id} to: #{euro_release_date.inspect}"
          attributes_to_update[:euro_date] = euro_release_date
        end
        release.update_attributes(attributes_to_update)

        # this is here because the release-search loop it's in can, and probably will, break at some point because the services times-out,
        # so we only want to check if we're finished if it doesn't break
        self.complete_release_dates_update_if_finished!(Release.last, release)
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
    def self.reset_metal_archives_data
      ::Rails.logger.info "\nCleaning up old data."
      #CompletedStep.destroy_all
      #SearchedAmazonDateRelease.destroy_all
      ::Rails.logger.info "\nData reset."
    end

    # If last album url is a url of a release, it's already looked at all of them.
    # If there is an album url that is nil, don't search for that because it will be a false-positive.
    def self.complete_releases_if_finished!
      last_album_url = AlbumUrl.try(:last) { |album_url| album_url.url }

      if !CompletedStep.finished_fetching_releases? && last_album_url.present? && Release.exists?(:url => last_album_url)
        ::Rails.logger.info "\nMetalDetectr::MetalArchives: completed fetching releases"
        CompletedStep.find_or_create_by_step(CompletedStep::ReleasesCollected)
      end
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
