class CompletedStep < ActiveRecord::Base
  AlbumUrlsCollected = 'album urls collected'
  ReleasesCollected  = 'releases collected'
  ReleasesUpdatedFromAmazon = 'releases updated from amazon'

  def self.finished_fetching_album_urls?
    self.find_by_step(CompletedStep::AlbumUrlsCollected).present?
  end

  def self.finished_fetching_releases?
    self.find_by_step(CompletedStep::ReleasesCollected).present?
  end

  def self.finished_updating_releases_from_amazon?
    self.find_by_step(CompletedStep::ReleasesUpdatedFromAmazon).present?
  end
end
