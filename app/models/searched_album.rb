class SearchedAlbum < ActiveRecord::Base
  belongs_to :album_url

  # Save the album url to search later if it doesn't already exist.
  def self.save_for_later(album_url)
    ::Rails.logger.info "Will search album url #{album_url.id} later."
    self.find_or_create_by_album_url_id(album_url.id)
  end
end
