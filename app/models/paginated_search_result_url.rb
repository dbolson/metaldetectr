class PaginatedSearchResultUrl < ActiveRecord::Base
  validates_presence_of :url
  validates_uniqueness_of :url

  # Finds the page number from the url eg, "/advanced.php?release_year=2011&p=1&p=32"
  def page_number
    match = /p=(\d+)$/.match(url)
    match ? match[1].to_i : -1
  end
end
