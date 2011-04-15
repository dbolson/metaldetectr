class SearchedAmazonDateRelease < ActiveRecord::Base
  belongs_to :release

  # Save the release to search later if it doesn't already exist.
  def self.save_for_later(release)
    ::Rails.logger.info "Will search amazon for release date for release #{release.id} later."
    self.find_or_create_by_release_id(release.id)
  end
end
