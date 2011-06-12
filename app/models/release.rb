class Release < ActiveRecord::Base
  # Formats the US release date to be human readable.
  def formatted_us_date
    self.us_date.strftime('%b %d, %Y') if self.us_date.present?
  end

  # Formats the Euro release date to be human readable.
  def formatted_euro_date
    self.euro_date.strftime('%b %d, %Y') if self.euro_date.present?
  end
end
