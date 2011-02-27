class CompletedStep < ActiveRecord::Base
  AlbumUrlsCollected = 1

  def self.finished_fetching_album_urls?
    self.find_by_step(CompletedStep::AlbumUrlsCollected).present?
  end
end
