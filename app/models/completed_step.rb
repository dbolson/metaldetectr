class CompletedStep < ActiveRecord::Base
  AlbumUrlsCollected = 1
  ReleasesCollected  = 2

  def self.finished_fetching_album_urls?
    self.find_by_step(CompletedStep::AlbumUrlsCollected).present?
  end

  def self.finished_fetching_releases?
    self.find_by_step(CompletedStep::ReleasesCollected).present?
  end
end
