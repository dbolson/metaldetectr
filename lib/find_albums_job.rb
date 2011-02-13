class FindAlbumsJob
  # Scrapes metal-archives.com for releases until all albums are searched.
  # It next finds all the releases on Amazon's US site and European sites to update the release dates if it can.
  # When all the albums have been searched, delete the obsolete data and send an email about the completion.
  def perform
    puts "performing job"
    #MetalArchivesRelease.generated_releases do
    #  Release.updated_amazon_release_dates do
    #    send_complete_notification
    #    reset_metal_archives_data
    #  end
    #end
  end

  # Erase data used to generate releases for new search for metal-archives.com.
  def reset_metal_archives_data
    ::Rails.logger.info "\nCleaning up old data."
    CompletedStep.delete_all
    MetalArchivesSearchedAlbum.delete_all
    MetalArchivesAlbumLink.delete_all
    MetalArchivesPaginatedResult.delete_all
    ::Rails.logger.info "\nData reset."
  end

  # Sends an email that says the data for the month is gathered.
  def send_complete_notification
    ReleaseMailer.finished_gathering_releases.deliver
  end
end
