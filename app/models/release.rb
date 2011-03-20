class Release < ActiveRecord::Base
  # Saves the release if it doesn't already exist.
  def self.create_from(album)
    ::Rails.logger.info "Creating release: #{album.inspect}"
    self.find_or_create_by_name_and_band_and_url(
      :name => album[:album],
      :band => album[:band],
      :format => album[:release_type],
      :label => album[:label],
      :url => album[:url],
      :us_date => album[:release_date]
    )
  end
end
