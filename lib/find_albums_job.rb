class FindAlbumsJob
  # Scrapes metal-archives.com for releases until all albums are searched.
  # It next finds all the releases on Amazon's US site and European sites to update the release dates if it can.
  # When all the albums have been searched, delete the obsolete data and send an email about the completion.
  def perform
    ::MetalDetectr::MetalArchives.generate_releases
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
