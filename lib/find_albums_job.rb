class FindAlbumsJob
  # Scrapes metal-archives.com for releases until all albums are searched.
  # It next finds all the releases on Amazon's US site and European sites to update the release dates if it can.
  # When all the albums have been searched, delete the obsolete data and send an email about the completion.
  def perform
    ::MetalDetectr::MetalArchives.fetch_paginated_result_urls do
      paginated_urls = MetalDetectr::MetalArchives.urls_to_search
      ::MetalDetectr::MetalArchives.fetch_album_urls(paginated_urls) do
        ::MetalDetectr::MetalArchives.complete_album_urls_fetch_if_finished!
        ::MetalDetectr::MetalArchives.releases_from_urls do
          ::MetalDetectr::MetalArchives.complete_releases_from_urls_if_finished!
          # MetalDetectr::Amazon.update_release_dates do
          #  reset_data
          #end
        end
      end
    end
  end

  # Erase data used to generate releases for new search for metal-archives.com.
  def reset_metal_archives_data
    ::Rails.logger.info "\nCleaning up old data."
    AlbumUrl.delete_all
    CompletedStep.delete_all
    PaginatedSearchResultUrl.delete_all
    SearchedAlbum.delete_all
    ::Rails.logger.info "\nData reset."
  end

  # Sends an email that says the data for the month is gathered.
  def send_complete_notification
    ReleaseMailer.finished_gathering_releases.deliver
  end
end

# rake watchr &
# spork &

# rake jobs:work
# bundle exec clockwork lib/clock.rb
