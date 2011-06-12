class CompletedStep < ActiveRecord::Base
  ReleasesCollected = 'releases collected'
  ReleasesUpdatedFromAmazon = 'releases updated from amazon'

  def self.finished_fetching_releases?
    self.where(:step => ReleasesCollected).count > 0
  end

  def self.finished_updating_releases_from_amazon?
    self.where(:step => ReleasesUpdatedFromAmazon).count > 0
  end
end
